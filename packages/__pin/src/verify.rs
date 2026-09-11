use std::collections::BTreeMap;
use std::collections::BTreeSet;
use std::collections::HashMap;
use std::path::Path;
use std::thread::scope;
use std::time::Duration;

use rootcause::Report;
use rootcause::Result;
use rootcause::option_ext::OptionExt as _;
use rootcause::prelude::ResultExt as _;
use rootcause::report;
use rootcause::report_collection::ReportCollection;

use crate::nix;
use crate::pins;

/// Concurrent narinfo fetches during a closure walk.
const WORKERS: usize = 16;

/// Verify the pins, in CI and locally:
///
/// 1. pins.json must match what the committed __pin lock evaluates to
///    (the lock moved without a refresh);
/// 2. every pinned closure must be substitutable from my cache plus
///    cache.nixos.org — never from the inputs' own caches. Cachix
///    never uploads paths that cache.nixos.org serves (verified: every
///    skipped path 404s on my cache and is on cache.nixos.org), and
///    machines keep cache.nixos.org configured regardless, so it does
///    not count as an upstream dependency. To check my cache strictly
///    alone, pass `--substituter` explicitly.
pub fn run(dir: &Path, substituters: &[String]) -> Result<()> {
    let dir = nix::pin_dir(dir)?;
    let committed = pins::read(&dir.join("pins.json"))?;
    let stage = nix::stage(&dir)?;

    let fresh: pins::Pins = serde_json::from_value(nix::eval_json(
        stage.path(),
        "pins",
        "eval the fresh pins from the staged flake",
    )?)
    .context("pins: unexpected shape")?;

    let mut failures: Vec<Report> = Vec::new();

    for line in drift_lines(&committed, &fresh) {
        println!("{line}");
        failures.push(report!("{line}"));
    }

    let subs = default_substituters(substituters)?;
    eprintln!("pins: verifying against {}", subs.join(", "));

    let agent = http_agent();
    let mut narinfos: HashMap<String, Option<Narinfo>> = HashMap::new();
    for coverage in walk_pins(&agent, &subs, &committed, &mut narinfos)? {
        println!("{}", coverage.line);
        for path in coverage.missing.iter().take(10) {
            println!("    {path}");
        }
        if !coverage.missing.is_empty() {
            failures.push(report!("{}", coverage.failure()));
        }
    }

    if failures.is_empty() {
        println!("pins verified.");
        Ok(())
    } else {
        let collection: ReportCollection = failures.into_iter().collect();
        Err(collection.context("pin verification failed").into())
    }
}

/// One package's cache coverage, as computed by [`walk_pins`].
pub struct Coverage {
    pub line: String,
    pub missing: Vec<String>,
}

impl Coverage {
    /// The failure text for this package (only meaningful when
    /// `missing` is non-empty).
    pub fn failure(&self) -> String {
        format!("{} ({UNCOVERED_HINT})", self.line)
    }
}

/// What it means when a path is in `missing`: re-run refresh-pin,
/// which substitutes from the upstream caches and pushes; cachix
/// skips only paths cache.nixos.org already serves.
pub const UNCOVERED_HINT: &str =
    "not substitutable; run refresh-pin to copy these closures";

/// The substituters the closure walk checks. Explicit flags win;
/// otherwise my cachix (from nix config) plus cache.nixos.org.
pub fn default_substituters(explicit: &[String]) -> Result<Vec<String>> {
    if !explicit.is_empty() {
        return Ok(explicit.to_vec());
    }
    let mut subs: Vec<String> = nix::configured_substituters()?
        .into_iter()
        .filter(|url| url.contains("cachix.org"))
        .collect();
    if subs.is_empty() {
        return Err(report!(
            "no cachix.org substituter in nix config; pass \
             --substituter"
        ));
    }
    subs.push(String::from("https://cache.nixos.org"));
    Ok(subs)
}

/// The agent shared by all narinfo fetches.
pub fn http_agent() -> ureq::Agent {
    ureq::Agent::config_builder()
        .timeout_global(Some(Duration::from_secs(30)))
        .build()
        .into()
}

/// Narinfo-walk every pinned closure. Nothing is downloaded; a missing
/// narinfo is a store path no listed substituter serves.
pub fn walk_pins(
    agent: &ureq::Agent,
    subs: &[String],
    pins: &pins::Pins,
    narinfos: &mut HashMap<String, Option<Narinfo>>,
) -> Result<Vec<Coverage>> {
    let mut out = Vec::new();
    for (system, pkgs) in pins {
        for (pkg, pin) in pkgs {
            let mut missing = Vec::new();
            let mut total = 0_usize;
            for out_path in pin.outputs.values() {
                walk_closure(
                    agent,
                    subs,
                    out_path,
                    narinfos,
                    &mut missing,
                    &mut total,
                )?;
            }
            let line = if missing.is_empty() {
                format!("- {pkg} ({system}): {total} path(s), all present")
            } else {
                format!(
                    "- {pkg} ({system}): MISSING {} of {total} path(s)",
                    missing.len()
                )
            };
            out.push(Coverage { line, missing });
        }
    }
    Ok(out)
}

/// Where pins.json and the committed lock disagree.
fn drift_lines(committed: &pins::Pins, fresh: &pins::Pins) -> Vec<String> {
    let mut lines = Vec::new();
    let systems: Vec<&String> = committed
        .keys()
        .chain(fresh.keys())
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect();
    for system in systems {
        let empty = BTreeMap::new();
        let old = committed.get(system.as_str()).unwrap_or(&empty);
        let new = fresh.get(system.as_str()).unwrap_or(&empty);
        for (pkg, pin) in old {
            match new.get(pkg.as_str()) {
                Some(fresh_pin) if fresh_pin == pin => {}
                Some(fresh_pin) => lines.push(format!(
                    "- {pkg} ({system}): pins.json {} but lock says {} \
                     (run refresh-pin)",
                    pin.label(),
                    fresh_pin.label()
                )),
                None => lines.push(format!(
                    "- {pkg} ({system}): in pins.json but not in the \
                     lock (run refresh-pin)"
                )),
            }
        }
        for pkg in new.keys() {
            if !old.contains_key(pkg.as_str()) {
                lines.push(format!(
                    "- {pkg} ({system}): in the lock but not in \
                     pins.json (run refresh-pin)"
                ));
            }
        }
    }
    lines
}

#[derive(Debug)]
#[derive(Clone)]
pub struct Narinfo {
    references: Vec<String>,
}

fn parse_narinfo(body: &str) -> Narinfo {
    let mut references = Vec::new();
    for line in body.lines() {
        if let Some(rest) = line.strip_prefix("References:") {
            references.extend(rest.split_whitespace().map(str::to_owned));
        }
    }
    Narinfo { references }
}

/// The digest half of a `/nix/store/<digest>-<name>` path.
fn store_hash(store_path: &str) -> Result<&str> {
    let name = store_path.rsplit('/').next().unwrap_or(store_path);
    Ok(name
        .get(..32)
        .context(format!("not a store path: {store_path}"))?)
}

/// Fetch one path's narinfo from the first substituter that has it;
/// `None` when none does. Transport-level failures are errors — a
/// broken cache must not read as "pin is missing".
fn fetch_narinfo(
    agent: &ureq::Agent,
    subs: &[String],
    path: &str,
) -> Result<Option<Narinfo>> {
    let hash = store_hash(path)?;
    for sub in subs {
        let url = format!("{}/{hash}.narinfo", sub.trim_end_matches('/'));
        match agent.get(&url).call() {
            Ok(mut response) => {
                let body = response
                    .body_mut()
                    .read_to_string()
                    .context(format!("read {url}"))?;
                return Ok(Some(parse_narinfo(&body)));
            }
            Err(ureq::Error::StatusCode(403 | 404)) => {}
            Err(error) => {
                return Err(report!(error)
                    .context(format!("fetch {url}"))
                    .into());
            }
        }
    }
    Ok(None)
}

/// Walk the closure of `root` through narinfo `References:` fields,
/// counting paths and collecting the ones no substituter has. Each
/// BFS level fetches concurrently: closures are hundreds of paths,
/// and sequential fetches through a proxy cost seconds each.
fn walk_closure(
    agent: &ureq::Agent,
    subs: &[String],
    root: &str,
    narinfos: &mut HashMap<String, Option<Narinfo>>,
    missing: &mut Vec<String>,
    total: &mut usize,
) -> Result<()> {
    let mut frontier = vec![root.to_owned()];
    let mut seen: BTreeSet<String> = BTreeSet::new();
    while !frontier.is_empty() {
        // Dedupe within the frontier and against past levels.
        frontier.retain(|path| seen.insert(path.clone()));

        // Expand already-cached paths; fetch the rest.
        let mut next: Vec<String> = Vec::new();
        let mut to_fetch: Vec<String> = Vec::new();
        for path in &frontier {
            match narinfos.get(path) {
                Some(Some(info)) => {
                    next.extend(info.references.iter().map(|reference| {
                        format!("/nix/store/{reference}")
                    }));
                }
                // Cached as absent: the walk ends at this path.
                Some(None) => {}
                None => to_fetch.push(path.clone()),
            }
        }
        if !to_fetch.is_empty() {
            eprintln!("pins: fetching {} narinfo(s)…", to_fetch.len());
            for (path, narinfo) in fetch_parallel(agent, subs, &to_fetch)?
            {
                if let Some(info) = &narinfo {
                    next.extend(info.references.iter().map(|reference| {
                        format!("/nix/store/{reference}")
                    }));
                }
                narinfos.insert(path, narinfo);
            }
        }
        frontier = next;
    }

    // Tally this walk's paths from the cache.
    for path in &seen {
        *total += 1;
        if narinfos.get(path).is_none_or(Option::is_none) {
            missing.push(path.clone());
        }
    }
    Ok(())
}

/// Fetch a level's narinfos with bounded concurrency.
fn fetch_parallel(
    agent: &ureq::Agent,
    subs: &[String],
    level: &[String],
) -> Result<Vec<(String, Option<Narinfo>)>> {
    let chunk_len = level.len().div_ceil(WORKERS).max(1);
    let mut results = Vec::with_capacity(level.len());
    scope(|scope| {
        let handles: Vec<_> = level
            .chunks(chunk_len)
            .map(|chunk| {
                scope.spawn(move || {
                    chunk
                        .iter()
                        .map(|path| {
                            fetch_narinfo(agent, subs, path)
                                .map(|narinfo| (path.clone(), narinfo))
                        })
                        .collect::<Result<Vec<_>>>()
                })
            })
            .collect();
        for handle in handles {
            // A panicking worker has no error value to keep.
            #[expect(
                clippy::map_err_ignore,
                reason = "join error is a panic payload"
            )]
            let chunk = handle
                .join()
                .map_err(|_| report!("narinfo worker panicked"))?;
            results.extend(chunk?);
        }
        Ok::<(), Report>(())
    })?;
    Ok(results)
}
