{ lib, pkgs, ... }:

{

  networking = {
      hostName = "lyfua";
      hostId = "66ccff70";
      nameservers = [ "127.0.0.1" ];
    };

  networking.networkmanager.enable = true;

  systemd.network.wait-online.extraArgs = [
      "--interface=wlp2s0:routable"
    ];

  services.resolved.extraConfig = ''
    Cache = no
    '';

}
