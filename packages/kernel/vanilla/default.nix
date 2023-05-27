{
  lib,
  callPackage,

  linuxManualConfig,
  pkgs,

  ...
}:

let

  baseKernel = pkgs.linux_6_3;

in

linuxManualConfig {

  inherit ( baseKernel )
    src version modDirVersion;

  configfile = ./configfile;
  allowImportFromDerivation = true;

  kernelPatches =
    baseKernel.kernelPatches
    ++ callPackage ./patches.nix {};

}
