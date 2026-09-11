use std::io::Read as _;
use std::path::Path;
use std::path::PathBuf;
use std::process::Command;
use std::process::Stdio;

use gix_discover::repository;
use rootcause::Result;
use rootcause::prelude::ResultExt as _;
use rootcause::report;
use serde_json::Value;

/// Locate the repo root, like `git rev-parse --show-toplevel`.
pub fn repo_root() -> Result<PathBuf> {
    let cwd = std::env::current_dir().context("get cwd")?;
    // Trust level is irrelevant here, only the path is used.
    let (path, _) =
        gix_discover::upwards(&cwd).context("locate git repo toplevel")?;
    match path {
        repository::Path::WorkTree(path) => Ok(path),
        repository::Path::LinkedWorkTree { .. }
        | repository::Path::Repository(_) => {
            Err(report!("other types of repo are not handled"))
        }
    }
}

/// Resolve the __pin directory: absolute paths win, relative ones are
/// taken against the repo root (so the tool works from any subdir).
pub fn pin_dir(dir: &Path) -> Result<PathBuf> {
    if dir.is_absolute() {
        Ok(dir.to_path_buf())
    } else {
        Ok(repo_root()?.join(dir))
    }
}

/// Copy the refresh manifest to a temporary flake. A checkout inside a
/// dirty repository is not itself a valid flake source because untracked
/// files are invisible.
pub fn stage(pin_dir: &Path) -> Result<tempfile::TempDir> {
    let stage = tempfile::TempDir::new().context("create staging dir")?;
    for name in ["flake.nix", "flake.lock"] {
        let from = pin_dir.join(name);
        let bytes = std::fs::read(&from)
            .context(format!("read {}", from.display()))?;
        std::fs::write(stage.path().join(name), bytes)
            .context(format!("stage {name}"))?;
    }
    Ok(stage)
}

/// Run to completion, capture both streams, fail with stderr in the
/// report. For commands whose output is consumed programmatically.
pub fn capture_checked(cmd: &mut Command, what: &str) -> Result<String> {
    let output = cmd.output().context(format!("spawn: {what}"))?;
    if !output.status.success() {
        return Err(report!(format!(
            "{what} failed ({}):\n{}",
            output.status,
            String::from_utf8_lossy(&output.stderr).trim(),
        ))
        .into());
    }
    Ok(String::from_utf8_lossy(&output.stdout).trim().to_owned())
}

/// Run to completion, capture stdout, let stderr stream to the
/// terminal. For long-running commands whose progress should be
/// visible (builds, pushes).
pub fn stream_checked(cmd: &mut Command, what: &str) -> Result<String> {
    let mut child = cmd
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit())
        .spawn()
        .context(format!("spawn: {what}"))?;
    let mut stdout = String::new();
    if let Some(mut pipe) = child.stdout.take() {
        pipe.read_to_string(&mut stdout)
            .context(format!("read stdout of: {what}"))?;
    }
    let status = child.wait().context(format!("wait: {what}"))?;
    if !status.success() {
        return Err(report!(format!("{what} failed ({status})")).into());
    }
    Ok(stdout.trim().to_owned())
}

/// `nix eval --json <flake>#<attr>`, parsed.
pub fn eval_json(flake: &Path, attr: &str, what: &str) -> Result<Value> {
    let out = capture_checked(
        Command::new("nix")
            .arg("eval")
            .arg("--json")
            .arg(format!("{}#{attr}", flake.display())),
        what,
    )?;
    Ok(serde_json::from_str(&out)
        .context(format!("{what}: parse eval output"))?)
}
