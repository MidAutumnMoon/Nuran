{
  sources,

  lib,
  callPackage,

  linuxManualConfig,
  linuxPackages_zen,

  ...
}:

let

  baseKernel = linuxPackages_zen.kernel;

  latestKernel = with sources.zen-kernel; {
    version = lib.removePrefix "v" version;
    inherit src;
  };

in

linuxManualConfig {

  inherit ( latestKernel )
    src version;

  modDirVersion =
    lib.versions.pad 3 latestKernel.version;

  isZen = true;

  configfile = ./configfile;
  allowImportFromDerivation = true;

  kernelPatches =
    baseKernel.kernelPatches
    ++ callPackage ./patches.nix {};

}
