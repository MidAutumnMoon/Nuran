{ lib, pkgs, ... }:

let

  xdotool = lib.getExe pkgs.xdotool;
  xprop = lib.getExe pkgs.xorg.xprop;

  blurScript = pkgs.writeScript "wezterm-blur" ''
    PID="$1"
    ${xdotool} search -pid "$PID" -sync \
    | xargs -I{} \
        ${xprop} -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c \
        -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 \
        -id {}
  '';

  blurScriptAsync = pkgs.writeScript "wezterm-blur-async" ''
    PID="$PPID"
    timeout 3 ${blurScript} "$PID" &
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
