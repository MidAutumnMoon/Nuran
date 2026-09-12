use std::collections::BTreeMap;
use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use serde::Deserialize;

use crate::nix;
use crate::pins;

#[derive(Debug)]
#[derive(Deserialize)]
struct Manifest {
    pins: pins::Pins,
    upstreams: BTreeMap<String, Upstream>,
}

#[derive(Debug)]
#[derive(Deserialize)]
struct Substituter {
    url: String,
    #[serde(rename = "public-key")]
    public_key: String,
}

#[derive(Debug)]
#[derive(Deserialize)]
struct Upstream {
    substituter: Substituter,
    /// System -> selected package names.
    packages: BTreeMap<String, Vec<String>>,
}

/// Refresh the pins:
///
/// 1. update the tracked lock and evaluate the manifest in its checkout;
/// 2. fetch every selected output through its upstream cache;
/// 3. push the resulting closures to my Cachix;
/// 4. publish the new pins.json.
pub fn run(dir: &Path, cachix: &str, no_push: bool) -> Result<()> {
    let flake = nix::pin_dir(dir)?;
    let old = pins::read(&flake.join("pins.json"))?;

    nix::stream_checked(
        Command::new("nix")
            .args(["flake", "update"])
            .current_dir(&flake),
        "nix flake update (pin manifest)",
    )?;

    let Manifest {
        pins: fresh,
        upstreams,
    } = serde_json::from_value(nix::eval_json(
        &flake,
        "manifest",
        "evaluate the pin manifest",
    )?)
    .context("pin manifest: unexpected shape")?;

    let mut paths = Vec::new();
    for (name, upstream) in &upstreams {
        let mut build = Command::new("nix");
        build.args(["build", "--no-link", "--print-out-paths"]);
        build
            .arg("--extra-substituters")
            .arg(&upstream.substituter.url);
        build
            .arg("--extra-trusted-public-keys")
            .arg(&upstream.substituter.public_key);

        let mut package_count = 0_usize;
        for (system, names) in &upstream.packages {
            for package in names {
                build.arg(format!(
                    "{}#upstream.{name}.packages.{system}.{package}^*",
                    flake.display()
                ));
                package_count += 1;
            }
        }
        if package_count == 0 {
            continue;
        }

        paths.extend(
            nix::stream_checked(
                &mut build,
                &format!("fetch {name} packages"),
            )?
            .lines()
            .map(str::to_owned),
        );
    }

    if !no_push && !paths.is_empty() {
        push(cachix, &paths)?;
    }

    // Publish consumer state only after fetch and push succeed.
    pins::write(&flake.join("pins.json"), &fresh)?;

    print!("{}", pins::diff_report(&old, &fresh));
    if no_push {
        println!("{} output path(s) fetched; push skipped.", paths.len());
    } else {
        println!(
            "{} output path(s) pushed to cachix \"{cachix}\".",
            paths.len()
        );
    }
    Ok(())
}

/// Push the realized closures. Cachix is not installed globally on every
/// caller, so fall back to `nix run`.
fn push(cachix: &str, paths: &[String]) -> Result<()> {
    let have_cachix = Command::new("cachix")
        .arg("--version")
        .output()
        .is_ok_and(|out| out.status.success());

    let mut cmd = if have_cachix {
        let mut cmd = Command::new("cachix");
        cmd.arg("push").arg(cachix).args(paths);
        cmd
    } else {
        let mut cmd = Command::new("nix");
        cmd.args(["run", "nixpkgs#cachix", "--", "push", cachix])
            .args(paths);
        cmd
    };
    nix::stream_checked(&mut cmd, "cachix push")?;
    Ok(())
}
