{ pkgs, ... }:

let

  tdropExec =
    lib.getExe pkgs.tdrop;


  tdrop_kitty_cmd = builtins.concatStringsSep " "
    [
      # make fcitx5 work
      "env"
      "GLFW_IM_MODULE=ibus"

      "${tdropExec}"

      # '%%' escapes '%' in xdg desktop file spec
      "--height 100%%" "--width 100%%"

      "--auto-detect-wm"
      "--monitor-aware"

      # tdrop doesn't work with an absolute path :(
      "kitty" "--class kitty_tdrop"
    ];


  tdrop_kitty_desktop = pkgs.makeDesktopItem
    {
      name = "tdrop-kitty";
      desktopName = "Tdrop & Kitty";
      exec = tdrop_kitty_cmd;
      icon = "kitty";
      categories = [ "TerminalEmulator" ];
    };

in

  tdrop_kitty_desktop
