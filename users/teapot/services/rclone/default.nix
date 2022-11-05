{ lib, pkgs, config, nixosConfig, ... }:

let

  builder = import ./builder.nix;

  homeDir =
    config.home.homeDirectory;

  sopsSecrets =
    nixosConfig.sops.secrets;

in

{ imports = [

  (builder {
      remoteName = "Hetzner";
      mountPoint = "${homeDir}/Remote/Hetzner";
      configPath = "${sopsSecrets.rclone_hetzner.path}";
      extraFlags =
        "--vfs-disk-space-total-size 1T";
    })

]; }
