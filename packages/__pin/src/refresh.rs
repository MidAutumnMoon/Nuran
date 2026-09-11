use std::collections::BTreeMap;
use std::collections::HashMap;
use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use serde::Deserialize;

use crate::nix;
use crate::pins;
use crate::verify::UNCOVERED_HINT;
use crate::verify::default_substituters;
use crate::verify::http_agent;
use crate::verify::walk_pins;

#[derive(Debug)]
#[derive(Deserialize)]
struct Substituter {
    url: String,
    #[serde(rename = "public-key")]
    public_key: String,
}

/// One upstream bundle, as the driver reads it: its cache and the
/// names it provides per system (the derivations themselves are only
/// addressable through the flake, not JSON-able).
#[derive(Debug)]
#[derive(Deserialize)]
struct Upstream {
    substituter: Substituter,
    packages: BTreeMap<String, Vec<String>>,
}

/// Refresh the pins: bump the staged __pin lock, eval the fresh
/// pins.json from it, build the real packages with each upstream's own
/// cache, push the closures to my cache, write lock + pins.json back,
/// and print the update report to stdout (for the PR body).
pub fn run(dir: &Path, cachix: &str, no_push: bool) -> Result<()> {
    let dir = nix::pin_dir(dir)?;
    let old = pins::read(&dir.join("pins.json"))?;
    let stage = nix::stage(&dir)?;
    let flake = stage.path();

    nix::stream_checked(
        Command::new("nix")
            .args(["flake", "update"])
            .current_dir(flake),
        "nix flake update (staged __pin flake)",
    )?;

    let fresh: pins::Pins = serde_json::from_value(nix::eval_json(
        flake,
        "pins",
        "eval the fresh pins from the staged flake",
    )?)
    .context("pins: unexpected shape")?;

    let upstreams: BTreeMap<String, Upstream> =
        serde_json::from_value(nix::eval_apply_json(
            flake,
            "upstream",
            "u: builtins.mapAttrs
                (_: up: {
                    substituter = up.substituter;
                    packages = builtins.mapAttrs
                        (_: ps: builtins.attrNames ps)
                        up.packages;
                })
                u",
            "read the upstream manifest from the staged flake",
        )?)
        .context("upstream: unexpected shape")?;

    // Substitute each upstream's packages from its own cache, so the
    // closures are local and can be pushed to mine. My machines then
    // never need the upstream caches.
    let mut paths: Vec<String> = Vec::new();
    for (name, upstream) in &upstreams {
        let mut build = Command::new("nix");
        build.args(["build", "--no-link", "--print-out-paths"]);
        build
            .arg("--extra-substituters")
            .arg(&upstream.substituter.url);
        build
            .arg("--extra-trusted-public-keys")
            .arg(&upstream.substituter.public_key);
        for (system, names) in &upstream.packages {
            for pkg in names {
                build.arg(format!(
                    "{}#upstream.{name}.packages.{system}.{pkg}",
                    flake.display()
                ));
            }
        }
        paths.extend(
            nix::stream_checked(
                &mut build,
                &format!("nix build {name} packages"),
            )?
            .lines()
            .map(str::to_owned),
        );
    }

    if !no_push && !paths.is_empty() {
        push(cachix, &paths)?;
    }

    // Write back only after a fully successful refresh.
    let lock = std::fs::read(flake.join("flake.lock"))
        .context("read staged flake.lock")?;
    std::fs::write(dir.join("flake.lock"), &lock)
        .context("write back flake.lock")?;
    pins::write(&dir.join("pins.json"), &fresh)?;

    print!("{}", pins::diff_report(&old, &fresh));

    // What the push left uncovered, under the same contract verify
    // checks: my cachix plus cache.nixos.org. Cachix never uploads
    // paths cache.nixos.org already serves, so those legitimately stay
    // off my cache; anything else missing means the push failed
    // somewhere.
    if no_push || paths.is_empty() {
        println!("{} package path(s) built; push skipped.", paths.len());
    } else {
        let subs = default_substituters(&[])?;
        let mut uncovered = 0_usize;
        let agent = http_agent();
        let mut narinfos = HashMap::new();
        for coverage in walk_pins(&agent, &subs, &fresh, &mut narinfos)? {
            println!("{}", coverage.line);
            for path in coverage.missing.iter().take(10) {
                println!("    {path}");
            }
            uncovered += coverage.missing.len();
        }
        println!(
            "{} package path(s) pushed to cachix \"{cachix}\"{}.",
            paths.len(),
            if uncovered == 0 {
                String::from("; closures fully covered")
            } else {
                format!(
                    "; WARNING: {uncovered} path(s) uncovered — \
                     {UNCOVERED_HINT}"
                )
            }
        );
    }
    Ok(())
}

/// Push the closures; cachix is not installed globally, so fall back to
/// `nix run nixpkgs#cachix` (auth comes from `cachix` login state or
/// `CACHIX_AUTH_TOKEN`).
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
