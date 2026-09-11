# Pinned Packages

Utilize `builtins.appendContext` to cut evaluation time. Oh, and
potentially cut metric tons of flake inputs.

Prior art:

- https://github.com/fzakaria/nixpkgs-multiverse
- https://github.com/tomberek/fastpkgs

Adopted to suite my repo.

## How it works

An input flake (`llm-agents`) is evaluated *once*, off the critical
path: a capture records each package's store paths and metadata into
`pins.json` (system -> package). From then on the driver
(`driver.nix`) reassembles "fake derivations" from the JSON —
`outPath` strings carrying `{ path = true }` context — and the root
overlay serves those through `default.nix` (`inherit (pinned) …`).
The input is not in the root flake at all.

**A pin can only be substituted, never rebuilt** — there is no `.drv`
behind it (asking for `drvPath` throws with guidance; build outputs,
e.g. `nix build .#zcode.out`). The trade is accepted: evaluation of
the whole input subtree is gone, every rebuild.

## The manifest

`flake.nix` here is a manifest for the pin driver, nothing more:

- inputs — where packages come from, pinned by this directory's lock;
- `pinnedNames` — which packages become pins, searched in the union
  of all inputs' packages;
- `substituters` — the upstream caches refresh substitutes from
  before pushing to my own. My machines never see them.

Its outputs follow directly: `packages` (the real derivations, what
refresh builds and pushes), `pins` (the fresh pins.json, what refresh
writes and verify re-evals). `facts.nix` is the mechanics of turning
a package into JSON; `driver.nix`/`default.nix` the overlay's view.

## The driver (this directory's crate)

Two subcommands, tied to CI:

- `refresh-pin` (update-sources.yml, or locally): stages this dir to
  a temp copy (a dirty git tree is not a valid flake source), runs
  `nix flake update` there, evals the fresh pins.json, realizes the
  real packages with the upstream substituters (`--extra-substituters`,
  no nix.conf edits), pushes the closures to my cachix (`cachix push`,
  falling back to `nix run nixpkgs#cachix`), writes lock + pins.json
  back, re-checks coverage, and prints the update report to stdout
  (the PR body).
- `verify-pin` (build.yml, or locally): re-evals the fresh pins from
  the *committed* lock and diffs against the committed pins.json, then
  narinfo-walks every pinned closure (concurrently, nothing
  downloaded). Drift or uncovered paths fail the build.

Pin one more package: add its name to `pinnedNames`, run
`refresh-pin`, consume it in `packages/default.nix`.

## Cache semantics

Cachix never uploads paths that cache.nixos.org already serves
(verified empirically: every skipped path 404s on my cache and is on
cache.nixos.org; paths from nowhere else upload fine). So "copied to
my cache" in practice means: my cachix holds everything *except* the
cache.nixos.org-served remainder of the closures. Accordingly:

- refresh's coverage check and verify-pin both default to
  **my cachix + cache.nixos.org** — machines keep cache.nixos.org
  configured for the rest of NixOS anyway, and no *upstream* cache
  (e.g. numtide's) is ever consulted after a refresh.
- verify-pin accepts explicit `--substituter` flags for a stricter
  check (e.g. my cache alone).

## Gotchas

- Everything here must be `git add`ed — untracked files are invisible
  to the root flake (`packages/default.nix` imports `./__pin`).
- `nix flake check` cannot deep-check fakes (`drvPath` throws); it
  already fails on the root flake for other reasons anyway.
- Between capture and deploy nothing GC-roots a pin; a gc'd path
  re-substitutes from my cache.
