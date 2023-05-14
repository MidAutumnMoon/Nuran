{
  callPackage,

  linuxManualConfig,
  linuxPackages_zen,

  ...
}:

let

  baseKernel = linuxPackages_zen.kernel;

in

linuxManualConfig {

  inherit ( baseKernel )
    src version modDirVersion;

  isZen = true;

  configfile = ./configfile;
  allowImportFromDerivation = true;

  kernelPatches =
    baseKernel.kernelPatches
    ++ callPackage ./patches.nix {};

}
