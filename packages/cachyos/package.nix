{
    lib,
    callPackage,
    linuxKernel,
    writers,
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

    gen-config =
        (writers.writePython3Bin "cachyos-gen-config" { }
            (builtins.readFile ./gen-config.py))
        .overrideAttrs (old: {
            meta = (old.meta or { }) // {
                description = "Generate Nix metadata from a Linux kernel .config";
                mainProgram = "cachyos-gen-config";
                platforms = lib.platforms.all;
            };
        });

}
