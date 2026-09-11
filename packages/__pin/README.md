# Pinned Packages

Store-path pins remove expensive upstream flakes from normal evaluation. The
refresh producer and normal consumers meet only at `pins.json`.

Prior art:

- https://github.com/fzakaria/nixpkgs-multiverse
- https://github.com/tomberek/fastpkgs

## Dataflow

### Refresh

`flake.nix` is a refresh-only manifest. Each `upstream.<name>` bundle owns:

- the upstream flake;
- the substituter needed to fetch it;
- the packages selected from that flake, for every system it provides.

`refresh-pin` stages and updates that flake, then evaluates its single JSON
`manifest` output. The output contains the fresh pin records and a JSON view of
the upstream package selections. Refresh then:

1. builds every selected package output through its upstream substituter;
2. pushes the realized closures to my Cachix;
3. writes `flake.lock` and `pins.json` back only after those steps succeed;
4. prints the pin diff to stdout for the update PR.

`--no-push` deliberately stops after fetching and still writes the generated
files.

### Consumption

The root overlay imports `default.nix`, which reads only `pins.json`.
`default.nix` reconstructs package-shaped values whose output paths carry
constant string context via `builtins.appendContext`. Nix therefore realizes
them through the consumer's ordinary configured substituters without evaluating
the upstream flake.

A pin has no derivation and cannot be rebuilt if substitution fails. Build an
explicit output, for example:

```console
nix build .#zcode.out
```

`pins.json` preserves each derivation's output order; the first captured output
remains the hydrated package's default output.

### Verification

`verify-pin` is a consumer smoke test. It reads committed `pins.json` only to
enumerate every system, package, and output, then runs one ordinary `nix build`
against the corresponding root-flake output attributes:

```text
<repo>#packages.<system>.<package>.<output>
```

It does not stage or evaluate the refresh manifest, inspect `flake.lock`, name
upstream substituters, or implement cache protocols. CI configures only the
normal consumer caches for this job; a missing pin therefore fails exactly as
it would for a machine consuming the overlay.

## Manifest

Add an upstream or package in `flake.nix`:

```nix
upstream.llm-agents = rec {
    flake = flakes.llm-agents;
    substituter = {
        url = "https://cache.numtide.com";
        public-key = "…";
    };
    packages = pkgsFrom flake (pkgs: {
        inherit (pkgs) omp zcode;
    });
};
```

Then run `refresh-pin` and export the package from `packages/default.nix`.
Systems follow the upstream package sets. If two upstreams select the same
package name for one system, the lexically later upstream name wins.

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
