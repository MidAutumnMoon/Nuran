{ pkgs, lib, ... }:

{

  services.xserver = {
      displayManager.defaultSession = "plasmawayland";
      displayManager.sddm.enable = true;
    };

  services.xserver.desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
      phononBackend = "vlc";
    };

  programs.dconf.enable = true;

  environment.systemPackages =
    with pkgs;
    with plasma5Packages;
    with kdeGear;
    [
      kde-gtk-config
      unzip
      unrar

      papirus-icon-theme
      graphite-cursor-theme
      breeze-gtk

      kate
      ark
      okular
      qimgv-teapot

      krunner fcitx5-qt ksshaskpass
    ];

}
