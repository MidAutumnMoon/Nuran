{
    callPackage,
    teapot,

    linuxManualConfig,
    pkgs,

    ...
}:

let

    baseKernel = pkgs.linux_6_6;

in

( linuxManualConfig {

    inherit ( baseKernel )
        src version modDirVersion;

    configfile = ./configfile;
    allowImportFromDerivation = true;

    kernelPatches =
        baseKernel.kernelPatches
        ++ callPackage ./patches.nix {};

} ).overrideDerivation ( oldDrv: let

    KCFLAGS = toString [
        "-march=${teapot.march}"
        "-mtune=${teapot.mtune}"
        "-pipe"
    ];

in {

    preConfigure = oldDrv.preConfigure or "" + ''
        makeFlagsArray+=(
            KCFLAGS="${KCFLAGS}"
        )
        export ZSTD_CLEVEL=19
    '';

} )
