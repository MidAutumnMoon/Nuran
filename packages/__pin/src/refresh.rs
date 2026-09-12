use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::report;
use serde::Deserialize;

use crate::nix;
use crate::pins;

#[derive(Debug)]
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Manifest {
    pins: pins::Pins,
    substituters: Vec<String>,
    #[serde(rename = "trusted-public-keys")]
    trusted_public_keys: Vec<String>,
}

/// Update the lock, realize every selected store path through the upstream
/// caches, optionally push those closures, then publish pins.json.
pub fn run(dir: &Path, cachix: &str, no_push: bool) -> Result<()> {
    let flake = nix::pin_dir(dir)?;
    let old = pins::read(&flake.join("pins.json"))?;

    nix::run_checked(
        Command::new("nix")
            .args(["flake", "update"])
            .current_dir(&flake),
        "nix flake update (pin manifest)",
    )?;

    let Manifest {
        pins: fresh,
        substituters,
        trusted_public_keys,
    } = nix::eval_json(&flake, "manifest", "evaluate the pin manifest")?;

    let package_count = pins::paths(&fresh).count();
    if package_count == 0 {
        return Err(report!("pin manifest contains no packages"));
    }

    let mut build = Command::new("nix");
    build.args(["build", "--no-link", "--print-build-logs"]);
    for substituter in &substituters {
        build.arg("--extra-substituters").arg(substituter);
    }
    for public_key in &trusted_public_keys {
        build.arg("--extra-trusted-public-keys").arg(public_key);
    }
    build.args(pins::paths(&fresh));

    nix::run_checked(&mut build, "fetch pinned paths")?;

    if !no_push {
        push(cachix, &fresh)?;
    }

    // Publish consumer state only after fetch and push succeed.
    pins::write(&flake.join("pins.json"), &fresh)?;

    print!("{}", pins::diff_report(&old, &fresh));
    if no_push {
        println!("{package_count} package(s) fetched; push skipped.");
    } else {
        println!(
            "{package_count} package(s) pushed to cachix \"{cachix}\"."
        );
    }
    Ok(())
}

/// Push the realized closures. Cachix is not installed globally on every
/// caller, so fall back to `nix run`.
fn push(cachix: &str, pinset: &pins::Pins) -> Result<()> {
    let have_cachix = Command::new("cachix")
        .arg("--version")
        .output()
        .is_ok_and(|out| out.status.success());

    let mut cmd = if have_cachix {
        let mut cmd = Command::new("cachix");
        cmd.arg("push").arg(cachix).args(pins::paths(pinset));
        cmd
    } else {
        let mut cmd = Command::new("nix");
        cmd.args(["run", "nixpkgs#cachix", "--", "push", cachix])
            .args(pins::paths(pinset));
        cmd
    };
    nix::run_checked(&mut cmd, "cachix push")
}
