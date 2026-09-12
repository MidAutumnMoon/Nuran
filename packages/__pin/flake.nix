{
    # Do not override the input's nixpkgs: refresh relies on its cache.
    inputs.llm-agents.url = "github:numtide/llm-agents.nix";

    outputs = { llm-agents, ... }: {
        manifest = {
            substituters = [
                "https://cache.numtide.com"
            ];
            trusted-public-keys = [
                "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            ];
            pins =
                builtins.mapAttrs (_system: packages: {
                    omp = packages.omp.outPath;
                    zcode = packages.zcode.outPath;
                }) llm-agents.packages;
        };
    };
}
