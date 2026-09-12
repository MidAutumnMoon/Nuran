# Pinned Packages

Store-path pins remove expensive upstream flakes from normal evaluation. The
refresh producer and normal consumers meet only at `pins.json`.

Prior art:

- https://github.com/fzakaria/nixpkgs-multiverse
- https://github.com/tomberek/fastpkgs

## Dataflow

### Refresh

`flake.nix` exposes one JSON `manifest` containing:

- the upstream substituters and trusted public keys;
- `pins`, mapping each selected package directly to its default output store
  path.

There is no parallel derivation tree or package-name mirror. Nix accepts store
paths as installables, so refresh can realize the exact manifest paths without
retaining an upstream package output.

Refresh passes each entry as a repeated `--extra-substituters` or
`--extra-trusted-public-keys` option. These append to the caller's configured
lists, like the corresponding `extra-*` settings in `nix.conf`; they do not
replace the normal caches. Trusted keys are one global set, not paired with
individual cache URLs.
An empty list emits no option and leaves that setting to the ambient Nix
configuration.

`refresh-pin` updates and evaluates that flake directly in the checkout. Both
Nix files are tracked, so the Git-backed flake exposes them without a staging
copy. Refresh then:

1. updates `flake.lock` and evaluates `manifest`;
2. realizes every selected store path through the upstream substituters;
3. optionally pushes those closures to my Cachix;
4. writes `pins.json` and prints the pin diff to stdout for the update PR.

If evaluation, fetching, or pushing fails, the updated lock remains as an
ordinary Git working-tree change while `pins.json` stays untouched. Rerun to
continue from that lock, or use Git to discard it.

A refresh that reproduces the committed pins is a no-op: the lock is restored
to its pre-update content, fetch and push are skipped, and `pins.json` is left
alone, so the working tree stays clean and no update PR is opened. The lock
only ever travels with an actual pin change.

`--no-push` still fetches the paths before publishing `pins.json`.

### Consumption

The root overlay imports `default.nix`, which reads only `pins.json`. Its wire
format is `system -> package -> default output store path`.

`pins.json` is required tracked consumer state. Refresh replaces it; it does
not bootstrap a missing file.

`default.nix` gives each path constant string context with
`builtins.appendContext`, then exposes a minimal one-output package value with
`.out` and `.outPath`. Nix can therefore realize it through the consumer's
ordinary configured substituters without evaluating the upstream flake.

A pin has no derivation and cannot be rebuilt if substitution fails. Build its
explicit output, for example:

```console
nix build .#zcode.out
```

Only the default output is pinned. Upstream package metadata is deliberately
not persisted.

### Verification

`verify-pin` is a consumer smoke test. It reads committed `pins.json` only to
enumerate every system and package, then runs one ordinary `nix build` against
the corresponding root-flake output:

```text
<repo>#packages.<system>.<package>.out
```

It does not evaluate the refresh manifest, inspect `flake.lock`, name the
upstream substituters, or implement cache protocols. CI configures only the
normal consumer caches for this job; a missing pin therefore fails exactly as
it would for a machine consuming the overlay.

## Manifest

Add a package to the path selection in `flake.nix`:

```nix
pins =
    builtins.mapAttrs (_system: packages: {
        omp = packages.omp.outPath;
        zcode = packages.zcode.outPath;
    }) llm-agents.packages;
```

Then run `refresh-pin` and export the package from `packages/default.nix`.
Systems follow the upstream package sets. The manifest intentionally models
one package source and a flat cache list; it does not assign packages to
particular caches.

## Cache semantics

Cachix does not upload paths already served by `cache.nixos.org`. Consumers are
therefore expected to configure my Cachix and `cache.nixos.org`; they never need
the manifest's upstream caches.

Between refresh and deployment nothing GC-roots a pin. A collected path is
substituted again from those normal consumer caches.

## Commands

```console
nix run .#tsuki.__pin -- refresh-pin
nix run .#tsuki.__pin -- refresh-pin --no-push
nix run .#tsuki.__pin -- verify-pin
```

Everything under this directory must be tracked before the root flake can see
it; untracked files are excluded from Git-backed flake sources.
