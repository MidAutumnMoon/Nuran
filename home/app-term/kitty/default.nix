{ lib, config, pkgs, ... }:

let

  kittyNoBorder = pkgs.writeShellScript "kitty-class-no-border" ''
    exec ${lib.getExe pkgs.kitty} --class kitty_no_border
    '';

  kittyNoBorderDesktop = pkgs.makeDesktopItem
    { name = "kitty-no-border";
      desktopName = "Kitty No Border";
      icon = "kitty";
      exec =
        "${toString kittyNoBorder}";
      categories =
        [ "System" "TerminalEmulator" ];
    };

in

lib.condMod (config.programs.kitty.enable) {

  home.packages = [
      kittyNoBorderDesktop
    ];

  programs.kitty.extraConfig = ''
    ${ builtins.readFile ./kitty.conf }
    '';

  # Remeber to use "Force Blur" the
  # Kwin script to make kitty blury.

}
