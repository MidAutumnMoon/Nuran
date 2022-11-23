{ pkgs, ... }:

{

  networking = {
      hostName = "lyfua";
      hostId = "66ccff70";
      nameservers = [ "127.0.0.1" ];
    };

  networking.networkmanager.enable = true;

}
