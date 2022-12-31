{ lib, pkgs, config, ... }:


{

  boot.kernelPackages =
    if config.boot.zfs.enabled
    then
      pkgs.linuxPackages
    else
      pkgs.linuxPackages_latest;

}
