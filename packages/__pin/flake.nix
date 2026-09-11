{
    # Notice for inputs:
    #
    # 1. Avoid override nixpkgs (for cache).
    inputs = {
        llm-agents.url = "github:numtide/llm-agents.nix";
    };

    outputs = { self, ... } @ flakes:
    let

        # The manifest, consumed by the pin driver: which packages
        # become pins (searched across all inputs), and which upstream
        # caches refresh substitutes from before pushing to my own.
        # My machines never see the upstream caches.
        pinnedNames = [ "omp" "zcode" ];
        substituters = [
            {
                url = "https://cache.numtide.com";
                public-key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
            }
        ];

        systems = [ "x86_64-linux" ];

        # Every input's packages merged into one set per system: the
        # single namespace pins live in. A name provided by two inputs
        # resolves to the later input, deterministically.
        packages =
            builtins.listToAttrs (
                map (system: {
                    name = system;
                    value =
                        builtins.foldl'
                            (merged: input:
                                merged // input.packages.${system} or { }
                            )
                            { }
                            (builtins.attrValues (
                                builtins.removeAttrs flakes [ "self" ]
                            ));
                }) systems
            );

    in
    {

        inherit substituters packages;

        # The fresh pins.json: facts for the pinned names, in exactly
        # the file's shape (system -> package). refresh writes this
        # out; verify re-evals it and expects the file to match.
        pins =
            builtins.mapAttrs (system: pkgs:
                import ./facts.nix {
                    names = pinnedNames;
                    packages = pkgs;
                }
            ) packages;

    };
}
