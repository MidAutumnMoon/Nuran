{
    # Do not override an input's nixpkgs: refresh relies on its cache.
    inputs = {
        llm-agents.url = "github:numtide/llm-agents.nix";
    };

    outputs = flakes:
    let

        # Select packages for every system provided by an upstream.
        pkgsFrom = flake: select:
            builtins.mapAttrs (_system: pkgs: select pkgs)
                flake.packages;

        # The refresh-only manifest. Each bundle owns both its selected
        # packages and the cache from which they can be substituted.
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

        # Merge systems without dropping systems absent from a later
        # upstream. Package names from lexically later upstream names win.
        mergePackages =
            merged: incoming:
            builtins.foldl'
                (all: system:
                    all // {
                        ${system} =
                            (all.${system} or { }) // incoming.${system};
                    }
                )
                merged
                (builtins.attrNames incoming);

        packages =
            builtins.foldl'
                (merged: source:
                    mergePackages merged source.packages
                )
                { }
                (builtins.attrValues upstream);

        # Drop individual metadata fields that cannot cross the JSON
        # boundary instead of aborting the entire capture.
        jsonMeta =
            meta:
            builtins.listToAttrs (
                builtins.concatMap (name:
                    let
                        value =
                            builtins.tryEval (builtins.toJSON meta.${name});
                    in
                    if value.success then
                        [{
                            inherit name;
                            value = builtins.fromJSON value.value;
                        }]
                    else
                        [ ]
                ) (builtins.attrNames meta)
            );

        capture =
            _name: package:
            {
                inherit (package) name pname;
                version = package.version or null;
                # Preserve declaration order: the first output is the
                # derivation's default output.
                outputs = map
                    (name: {
                        inherit name;
                        path = package.${name}.outPath;
                    })
                    package.outputs;
                meta = jsonMeta (package.meta or { });
            };

    in {

        # Real derivations addressed by refresh when fetching from each
        # upstream cache.
        inherit upstream;

        # The single JSON value consumed by refresh-pin.
        manifest = {
            pins =
                builtins.mapAttrs
                    (_system: builtins.mapAttrs capture)
                    packages;
            upstreams =
                builtins.mapAttrs (_name: source: {
                    inherit (source) substituter;
                    packages =
                        builtins.mapAttrs
                            (_system: builtins.attrNames)
                            source.packages;
                }) upstream;
        };

    };
}
