use std::collections::BTreeMap;
use std::collections::BTreeSet;
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

/// The update report: one `- pkg: old -> new` line per package whose pins
/// moved, or `None` when every package reproduced its committed pins.
/// Labels are versions; when a package's systems pin different versions,
/// the labels are joined.
pub fn diff_report(old: &Pins, fresh: &Pins) -> Option<String> {
    let old_by_pkg = transpose(old);
    let fresh_by_pkg = transpose(fresh);

    let mut packages: Vec<&str> = old_by_pkg
        .keys()
        .copied()
        .chain(fresh_by_pkg.keys().copied())
        .collect();
    packages.sort_unstable();
    packages.dedup();

    let mut changed = Vec::new();
    for pkg in packages {
        match (old_by_pkg.get(pkg), fresh_by_pkg.get(pkg)) {
            // Unchanged packages are not reported.
            (Some(old_systems), Some(fresh_systems))
                if old_systems == fresh_systems => {}
            (Some(old_systems), Some(fresh_systems)) => {
                changed.push(format!(
                    "- {pkg}: {} -> {}",
                    version_labels(old_systems),
                    version_labels(fresh_systems),
                ));
            }
            (None, Some(fresh_systems)) => changed.push(format!(
                "- {pkg}: added {}",
                version_labels(fresh_systems),
            )),
            (Some(_), None) => {
                changed.push(format!("- {pkg}: removed"));
            }
            // Union iteration never yields a package absent from both.
            (None, None) => {}
        }
    }

    if changed.is_empty() {
        None
    } else {
        Some(format!("## Pins\n\n{}\n", changed.join("\n")))
    }
}

/// pkg -> system -> path: the report's view. Versions belong to packages;
/// the per-system split is an artifact of store paths.
fn transpose(pins: &Pins) -> BTreeMap<&str, BTreeMap<&str, &str>> {
    let mut transposed: BTreeMap<&str, BTreeMap<&str, &str>> =
        BTreeMap::new();
    for (system, packages) in pins {
        for (pkg, path) in packages {
            transposed
                .entry(pkg.as_str())
                .or_default()
                .insert(system.as_str(), path.as_str());
        }
    }
    transposed
}

/// One package's pinned versions across its systems, joined where they
/// disagree.
fn version_labels(systems: &BTreeMap<&str, &str>) -> String {
    let labels: BTreeSet<&str> =
        systems.values().map(|path| label(path)).collect();
    labels.into_iter().collect::<Vec<_>>().join(", ")
}

/// The version of a store path: the component after the last '-'.
fn label(path: &str) -> &str {
    path.strip_prefix("/nix/store/")
        .and_then(|name| name.rsplit_once('-').map(|(_, version)| version))
        .unwrap_or(path)
}

#[cfg(test)]
mod tests {
    use super::Pins;
    use super::diff_report;
    use std::collections::BTreeMap;

    fn pins(entries: &[(&str, &str, &str)]) -> Pins {
        let mut pins = Pins::new();
        for (system, pkg, version) in entries {
            let path = format!(
                "/nix/store/0000000000000000000000000000000-{pkg}-{version}"
            );
            pins.entry(system.to_string())
                .or_default()
                .insert(pkg.to_string(), path);
        }
        pins
    }

    #[test]
    fn report_shows_one_line_per_package() {
        let old = pins(&[
            ("aarch64-darwin", "omp", "18.1.17"),
            ("aarch64-linux", "omp", "18.1.17"),
            ("x86_64-linux", "omp", "18.1.17"),
            ("aarch64-linux", "zcode", "3.11.2"),
            ("x86_64-linux", "zcode", "3.11.2"),
        ]);
        let fresh = pins(&[
            ("aarch64-darwin", "omp", "18.1.18"),
            ("aarch64-linux", "omp", "18.1.18"),
            ("x86_64-linux", "omp", "18.1.18"),
            ("aarch64-linux", "zcode", "3.11.3"),
            ("x86_64-linux", "zcode", "3.11.3"),
        ]);
        assert_eq!(
            diff_report(&old, &fresh).as_deref(),
            Some(
                "## Pins\n\n- omp: 18.1.17 -> 18.1.18\n- zcode: 3.11.2 -> 3.11.3\n"
            )
        );
    }

    #[test]
    fn report_lists_a_rebuild_with_the_same_version() {
        let old = pins(&[("x86_64-linux", "zcode", "3.11.2")]);
        let fresh = Pins::from([(
            "x86_64-linux".into(),
            BTreeMap::from([(
                "zcode".into(),
                "/nix/store/1111111111111111111111111111111-zcode-3.11.2"
                    .into(),
            )]),
        )]);
        assert_eq!(
            diff_report(&old, &fresh).as_deref(),
            Some("## Pins\n\n- zcode: 3.11.2 -> 3.11.2\n")
        );
    }

    #[test]
    fn report_is_none_when_nothing_moved() {
        let old = pins(&[
            ("aarch64-linux", "omp", "18.1.17"),
            ("x86_64-linux", "omp", "18.1.17"),
        ]);
        assert_eq!(diff_report(&old, &old), None);
    }

    #[test]
    fn report_covers_additions_and_removals() {
        let old = pins(&[("x86_64-linux", "omp", "18.1.17")]);
        let fresh = pins(&[("x86_64-linux", "zcode", "3.11.2")]);
        assert_eq!(
            diff_report(&old, &fresh).as_deref(),
            Some("## Pins\n\n- omp: removed\n- zcode: added 3.11.2\n")
        );
    }

    #[test]
    fn report_joins_versions_when_systems_disagree() {
        let old = pins(&[
            ("aarch64-linux", "omp", "18.1.16"),
            ("x86_64-linux", "omp", "18.1.17"),
        ]);
        let fresh = pins(&[
            ("aarch64-linux", "omp", "18.1.18"),
            ("x86_64-linux", "omp", "18.1.18"),
        ]);
        assert_eq!(
            diff_report(&old, &fresh).as_deref(),
            Some("## Pins\n\n- omp: 18.1.16, 18.1.17 -> 18.1.18\n")
        );
    }
}
