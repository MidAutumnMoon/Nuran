use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use rootcause::report;

use crate::nix;
use crate::pins;

/// Build every committed output through the root flake. This is the same
/// consumer path used by the overlay: pins.json is hydrated by default.nix,
/// and Nix uses only its ordinary configured substituters.
pub fn run(dir: &Path) -> Result<()> {
    let dir = nix::pin_dir(dir)?;
    let pins = pins::read(&dir.join("pins.json"))?;
    let root = nix::repo_root()?;

    let mut installables = Vec::new();
    for (system, packages) in &pins {
        let system_attr = quoted_attr(system)?;
        for (package, pin) in packages {
            if pin.outputs.is_empty() {
                return Err(report!(
                    "{package} ({system}) has no outputs"
                ));
            }
            let package_attr = quoted_attr(package)?;
            for output in &pin.outputs {
                let output_attr = quoted_attr(&output.name)?;
                installables.push(format!(
                    "{}#packages.{system_attr}.{package_attr}.{output_attr}",
                    root.display()
                ));
            }
        }
    }

    if installables.is_empty() {
        return Err(report!("pins.json contains no package outputs"));
    }

    let count = installables.len();
    nix::stream_checked(
        Command::new("nix")
            .args(["build", "--no-link", "--print-build-logs"])
            .args(installables),
        "build committed pins through the root flake",
    )?;
    println!("{count} pinned output(s) built.");
    Ok(())
}

/// Flake attribute paths accept JSON-style quoted components. Always quote
/// generated names so dots and other punctuation cannot change the path.
fn quoted_attr(name: &str) -> Result<String> {
    Ok(serde_json::to_string(name).context("quote flake attribute")?)
}
