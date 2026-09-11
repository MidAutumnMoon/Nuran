{
    # Notice for inputs:
    #
    # 1. Avoid override nixpkgs (for cache).
    inputs = {
        llm-agents.url = "github:numtide/llm-agents.nix";
    };

    outputs = { self, ... } @ flakes:
    let

        # Map a selection over an upstream flake's per-system package
        # sets: what this repo pins from that upstream, for every
        # system that upstream builds for.
        pkgsFrom = flake: select:
            builtins.mapAttrs (_system: pkgs: select pkgs)
                flake.packages;

        # The manifest, one bundle per upstream: the flake, the cache
        # refresh substitutes from before pushing to my own, and the
        # packages taken. My machines never see the upstream caches.
        upstream.llm-agents = rec {
            flake = flakes.llm-agents;
            substituter = {
                url = "https://cache.numtide.com";
                public-key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
            };
            packages = pkgsFrom flake (pkgs: {
                inherit (pkgs)
                    omp
                    zcode
                ;
            });
        };

        # All upstreams' selections merged into one namespace per
        # system: the single flat space pins live in. A name provided
        # by two upstreams resolves to the later one, deterministically.
        packages =
            builtins.foldl'
                (merged: upstream:
                    builtins.mapAttrs
                        (system: pkgs: merged.${system} or { } // pkgs)
                        upstream.packages
                )
                { }
                (builtins.attrValues upstream);

    in {

        inherit upstream;

        # The fresh pins.json: facts for the selected packages, in
        # exactly the file's shape (system -> package). refresh writes
        # this out; verify re-evals it and expects the file to match.
        pins =
            builtins.mapAttrs (system: pkgs:
                import ./facts.nix {
                    names = builtins.attrNames pkgs;
                    packages = pkgs;
                }
            ) packages;

    };
}
