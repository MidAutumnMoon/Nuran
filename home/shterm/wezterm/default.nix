{ lib, pkgs, ... }:

let

  xdotool = lib.getExe pkgs.xdotool;
  xprop = lib.getExe pkgs.xorg.xprop;

  blurScript = pkgs.writeScript "wezterm-blur" ''
    ${xdotool} search -classname org.wezfurlong.wezterm \
      | xargs -I{} \
        ${xprop} -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c \
        -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 \
        -id {}
  '';

  mainConfig = pkgs.substituteAll {
    src = ./wezterm.lua;
    inherit blurScript;
  };

in

{

  home.packages = with pkgs; [ wezterm ];

  xdg.configFile = {
    "wezterm/wezterm.lua".source = mainConfig;
  };

}
