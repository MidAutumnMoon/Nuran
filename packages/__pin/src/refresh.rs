use std::path::Path;
use std::process::Command;

use rootcause::Result;
use rootcause::prelude::ResultExt as _;
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

    // Snapshot the lock so a refresh that reproduces the committed pins can
    // leave the tree exactly as it found it. Absence is a valid snapshot.
    let lock = flake.join("flake.lock");
    let lock_before = std::fs::read(&lock)
        .map(Some)
        .or_else(|err| {
            if err.kind() == std::io::ErrorKind::NotFound {
                Ok(None)
            } else {
                Err(err)
            }
        })
        .context(format!("read {}", lock.display()))?;

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

    // A missing report means every package reproduced its committed pins:
    // the lock revision carries no consumer-visible change, and fetching
    // and pushing would only re-verify state an earlier refresh already
    // published.
    let Some(report) = pins::diff_report(&old, &fresh) else {
        restore_lock(&lock, lock_before)?;
        println!("Pins unchanged; flake.lock restored.");
        return Ok(());
    };

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

    print!("{report}");
    if no_push {
        println!("{package_count} package(s) fetched; push skipped.");
    } else {
        println!(
            "{package_count} package(s) pushed to cachix \"{cachix}\"."
        );
    }
    Ok(())
}

/// Put the pre-update lock back. `None` means there was no lock, so the
/// one `nix flake update` wrote is removed again.
fn restore_lock(lock: &Path, before: Option<Vec<u8>>) -> Result<()> {
    before
        .map_or_else(
            || std::fs::remove_file(lock),
            |bytes| std::fs::write(lock, bytes),
        )
        .context(format!("restore {}", lock.display()))?;
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

#[cfg(test)]
#[expect(clippy::unwrap_used, reason = "Tests")]
mod tests {
    use super::restore_lock;

    /// A no-op refresh leaves the lock byte-identical, and removes it
    /// entirely when there was none before the update.
    #[test]
    fn restore_lock_round_trips() {
        let dir = std::env::temp_dir().join(format!(
            "pin-driver-restore-lock-{}",
            std::process::id()
        ));
        std::fs::create_dir_all(&dir).unwrap();
        let lock = dir.join("flake.lock");

        std::fs::write(&lock, "updated").unwrap();
        restore_lock(&lock, Some(b"committed".to_vec())).unwrap();
        assert_eq!(std::fs::read(&lock).unwrap(), b"committed");

        restore_lock(&lock, None).unwrap();
        assert!(!lock.exists());

        std::fs::remove_dir_all(&dir).unwrap();
    }
}
