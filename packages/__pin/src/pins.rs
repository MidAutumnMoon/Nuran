use std::collections::BTreeMap;
use std::path::Path;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;

/// pins.json: system -> package -> default output store path.
pub type Pins = BTreeMap<String, BTreeMap<String, String>>;

/// Read the committed consumer state.
pub fn read(path: &Path) -> Result<Pins> {
    let text = std::fs::read_to_string(path)
        .context(format!("read {}", path.display()))?;
    Ok(serde_json::from_str(&text)
        .context(format!("parse {}", path.display()))?)
}

/// Write pins.json, sorted and pretty.
pub fn write(path: &Path, pins: &Pins) -> Result<()> {
    let mut text = serde_json::to_string_pretty(pins)
        .context("serialize pins.json")?;
    text.push('\n');
    Ok(std::fs::write(path, text)
        .context(format!("write {}", path.display()))?)
}

pub fn paths(pins: &Pins) -> impl Iterator<Item = &str> {
    pins.values()
        .flat_map(|packages| packages.values().map(String::as_str))
}

/// One `- pkg (system): old -> new` line per changed package, under a
/// heading; unchanged packages are counted, not listed.
pub fn diff_report(old: &Pins, fresh: &Pins) -> String {
    let mut lines = Vec::new();
    let mut unchanged = 0_usize;

    let systems: Vec<&String> = old
        .keys()
        .chain(fresh.keys())
        .collect::<std::collections::BTreeSet<_>>()
        .into_iter()
        .collect();

    for system in systems {
        let empty = BTreeMap::new();
        let old_pkgs = old.get(system.as_str()).unwrap_or(&empty);
        let fresh_pkgs = fresh.get(system.as_str()).unwrap_or(&empty);
        for (pkg, path) in fresh_pkgs {
            let change = match old_pkgs.get(pkg.as_str()) {
                Some(old_path) if old_path == path => {
                    unchanged += 1;
                    continue;
                }
                Some(old_path) => {
                    format!("{} -> {}", label(old_path), label(path))
                }
                None => format!("added {}", label(path)),
            };
            lines.push(format!("- {pkg} ({system}): {change}"));
        }
        for pkg in old_pkgs.keys() {
            if !fresh_pkgs.contains_key(pkg.as_str()) {
                lines.push(format!("- {pkg} ({system}): removed"));
            }
        }
    }

    let mut report = String::from("## Pins\n\n");
    if lines.is_empty() {
        report.push_str("No changes (");
        report.push_str(unchanged.to_string().as_str());
        report.push_str(" package(s) unchanged).\n");
    } else {
        for line in &lines {
            report.push_str(line);
            report.push('\n');
        }
    }
    report
}

fn label(path: &str) -> &str {
    path.strip_prefix("/nix/store/")
        .and_then(|name| name.split_once('-').map(|(_, label)| label))
        .unwrap_or(path)
}
