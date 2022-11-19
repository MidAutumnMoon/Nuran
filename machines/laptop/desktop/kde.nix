{ pkgs, lib, ... }:

{

  services.xserver = {
      displayManager.defaultSession = "plasmawayland";
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      desktopManager.plasma5.runUsingSystemd = true;
    };

  xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];

  nuran.fonts.enable = true;

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
      qimgv

      krunner fcitx5-qt ksshaskpass
    ];

}
