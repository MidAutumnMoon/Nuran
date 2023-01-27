{ lib, pkgs, config, ... }:


{

  boot.kernelPackages =
    pkgs.linuxPackages_latest;

}
