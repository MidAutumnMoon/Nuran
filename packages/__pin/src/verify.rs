use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use rootcause::report;

use crate::nix;
use crate::pins;

/// Build every committed default output through the root flake. This is
/// the consumer path: pins.json is hydrated by default.nix and Nix uses
/// only its ordinary configured substituters.
pub fn run(dir: &Path) -> Result<()> {
    let dir = nix::pin_dir(dir)?;
    let pins = pins::read(&dir.join("pins.json"))?;
    let root = nix::repo_root()?;

    let mut build = Command::new("nix");
    build.args(["build", "--no-link", "--print-build-logs"]);

    let mut package_count = 0_usize;
    for (system, packages) in &pins {
        for package in packages.keys() {
            build.arg(consumer_installable(&root, system, package)?);
            package_count += 1;
        }
    }
    if package_count == 0 {
        return Err(report!("pins.json contains no packages"));
    }

    nix::run_checked(
        &mut build,
        "build committed pins through the root flake",
    )?;
    println!("{package_count} pinned package(s) built.");
    Ok(())
}

/// Quote generated path components; punctuation in an attribute name must
/// not change which package verify builds.
fn consumer_installable(
    root: &Path,
    system: &str,
    package: &str,
) -> Result<String> {
    let system =
        serde_json::to_string(system).context("quote package system")?;
    let package =
        serde_json::to_string(package).context("quote package name")?;
    Ok(format!(
        "{}#packages.{system}.{package}.out",
        root.display()
    ))
}
