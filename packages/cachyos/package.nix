{
    lib,
    callPackage,
    linuxKernel,
}:

let

    release = import ./release.nix;
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

        generatedConfig = import ./config.nix;
    };

in {

    inherit kernel;

    linuxPackages = linuxKernel.packagesFor kernel;
}
