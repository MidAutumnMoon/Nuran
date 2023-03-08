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
