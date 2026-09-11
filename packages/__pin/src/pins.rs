use std::collections::BTreeMap;
use std::path::Path;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use serde::Deserialize;
use serde::Serialize;
use serde_json::Value;

/// pins.json: system -> package. The same shape the __pin flake's
/// `capture` output evals to — one authoritative shape.
pub type Pins = BTreeMap<String, BTreeMap<String, Pin>>;

/// Everything the driver needs to reassemble one package. Field-for-
/// field what capture.nix produces.
#[derive(Debug)]
#[derive(Clone)]
#[derive(Eq)]
#[derive(PartialEq)]
#[derive(Serialize, Deserialize)]
pub struct Pin {
    pub name: String,
    pub pname: String,
    pub version: Option<String>,
    /// output name -> out path.
    pub outputs: BTreeMap<String, String>,
    pub meta: BTreeMap<String, Value>,
}

impl Pin {
    /// How to name the package in reports: the version when captured,
    /// the derivation name otherwise.
    pub fn label(&self) -> String {
        self.version.clone().unwrap_or_else(|| self.name.clone())
    }
}

/// Read pins.json; a missing file reads as empty (first run writes it).
pub fn read(path: &Path) -> Result<Pins> {
    if !path.is_file() {
        return Ok(Pins::default());
    }
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
        for (pkg, pin) in fresh_pkgs {
            let change = match old_pkgs.get(pkg.as_str()) {
                Some(old_pin) if old_pin == pin => {
                    unchanged += 1;
                    continue;
                }
                Some(old_pin) => {
                    format!("{} -> {}", old_pin.label(), pin.label())
                }
                None => format!("added {}", pin.label()),
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
