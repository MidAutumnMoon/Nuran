{ lib, pkgs, ... }:

let

  xdotool = lib.getExe pkgs.xdotool;
  xprop = lib.getExe pkgs.xorg.xprop;

  blurScript = pkgs.writeShellScript "wezterm-blur" ''
    "${xdotool}" search -pid "$1" -sync \
    | xargs -I{} \
        "${xprop}" -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c \
        -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 \
        -id {}
  '';

  blurScriptAsync = pkgs.writeShellScript "wezterm-blur-async" ''
    timeout 3 "${blurScript}" "$PPID" &
    disown
  '';

  mainConfig = pkgs.substituteAll {
    src = ./wezterm.lua;
    inherit blurScriptAsync;
  };

in

{

  home.packages = with pkgs; [ wezterm ];

  xdg.configFile = {
    "wezterm/wezterm.lua".source = mainConfig;
  };

}
