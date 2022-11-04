{ pkgs, ... }:

{

  networking =
    { hostName = "aquae";
      hostId = "66ccff70";
      nameservers = [ "127.0.0.1" ];
    };

  environment.systemPackages = with pkgs;
    [ libimobiledevice ];

  services.usbmuxd.enable = true;

  networking.networkmanager.enable = true;

}
