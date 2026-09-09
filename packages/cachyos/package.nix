{
    lib,
    callPackage,
    linuxKernel,
}:

let

    release = builtins.fromJSON (builtins.readFile ./release.json);
    buildKernel = callPackage ./kernel.nix { };

    kernel = lib.makeOverridable buildKernel {
        inherit (release)
            pname
            version
            packageVersion
            architecture
            modDirVersion
            kernel
            headers
            configHash
            isLTS
            isZen
        ;

        generatedConfig =
            builtins.fromJSON (builtins.readFile ./config.json);
    };

in {

    inherit kernel;

    linuxPackages = linuxKernel.packagesFor kernel;
}
