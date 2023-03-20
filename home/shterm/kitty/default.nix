{ lib, pkgs, ... }:

let

  kittyNoBorder = pkgs.writeShellScript "kitty-class-no-border" ''
    export GLFW_IM_MODULE='ibus'
    exec ${lib.getExe pkgs.kitty} --class kitty_no_border
    '';

  kittyNoBorderDesktop = pkgs.makeDesktopItem {
      name = "kitty-no-border";
      desktopName = "Kitty No Border";
      icon = "kitty";
      exec = "${toString kittyNoBorder}";
      categories = [ "TerminalEmulator" ];
    };

in

{

  home.packages = [ kittyNoBorderDesktop ];

  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;

  # Remeber to use "Force Blur" the
  # Kwin script to make kitty blury.

}
