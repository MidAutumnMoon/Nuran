{
    callPackage,
    teapot,

    linuxManualConfig,
    pkgs,

    ...
}:

let

    baseKernel = pkgs.linux_6_3;

in

( linuxManualConfig {

    inherit ( baseKernel )
        src version modDirVersion;

    configfile = ./configfile;
    allowImportFromDerivation = true;

    kernelPatches =
        baseKernel.kernelPatches
        ++ callPackage ./patches.nix {};

} ).overrideDerivation ( oldDrv: {

    preConfigure = oldDrv.preConfigure or "" + ''
        makeFlagsArray+=(
          KCFLAGS="${toString teapot.baseOptimiz}"
        )
    '';

} )
