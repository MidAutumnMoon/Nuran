{ lib, ... }:

{

  networking = {
    hostName = "lyfua";
  };

  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [];
  };

  systemd.network.wait-online.extraArgs = [
    "--interface=wlp2s0:routable"
  ];

}
