{ pkgs, lib, ... }:

let

  greetd-script = pkgs.writers.writeFish "greetd-script" ''
    exec '${lib.getExe pkgs.greetd.tuigreet}' \
      --sessions '/run/current-system/sw/share/wayland-sessions' \
      --time \
      --remember \
      --remember-user-session \
      --cmd 'startplasma-wayland'
    '';

in

{

  #
  # Display Manager
  #

  # xserver module defaults to enable lightdm
  # if no other display managers are enabled :(
  services.xserver.displayManager.lightdm.enable = false;

  services.greetd = {
      enable = true;
      vt = 2;
    };

  services.greetd.settings = {
      default_session.command = greetd-script;
    };

  security.pam.services.greetd.enableKwallet = true;

  systemd.services.greetd.serviceConfig = {
      # Type = idle slows down the login flow a lot
      Type = lib.mkForce "simple";
    };

  systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter - -"
    ];



  #
  # KDE
  #

  programs.dconf.enable = true;

  services.xserver.desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
      phononBackend = "vlc";
    };

  environment.systemPackages =
    with pkgs;
    with plasma5Packages;
    with kdeGear;
    [
      kde-gtk-config
      fcitx5-qt ksshaskpass

      papirus-icon-theme
      graphite-cursor-theme
      breeze-gtk

      unzip unrar
      kate ark
      okular
      qimgv
    ];



  #
  # IME
  #

  i18n.inputMethod.enabled = "fcitx5";

  i18n.inputMethod.fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-chinese-addons
    ];

}
