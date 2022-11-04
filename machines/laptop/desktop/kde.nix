{ pkgs, lib, ... }:

{

  services.xserver = {
      displayManager.defaultSession = "plasmawayland";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      desktopManager.plasma5.runUsingSystemd = true;
    };

  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-gtk ];

  nuran.fonts.enable =
    true;

  environment.systemPackages =
    with pkgs;
    with plasma5Packages;
    with kdeGear;
    [
      kde-gtk-config
      unzip unrar
      qtimageformats

      papirus-icon-theme
      graphite-cursor-theme
      breeze-gtk

      kate ark okular
      krunner fcitx5-qt ksshaskpass
      qimgv
    ];

}
