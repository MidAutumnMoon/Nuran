{ lib, pkgs, ... }:

let

    xdotool = lib.getExe pkgs.xdotool;
    xprop = lib.getExe pkgs.xorg.xprop;
    timeout = "${pkgs.coreutils}/bin/timeout";
    xargs = "${pkgs.findutils}/bin/xargs";

    blurScript = pkgs.writeShellScript "wez-blur" ''
        "${xdotool}" search -pid "$1" -sync \
        | "${xargs}" -I{} \
            "${xprop}" -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c \
            -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 \
            -id {}
    '';

    blurScriptAsync = pkgs.writeShellScript "wez-blur-async" ''
        "${timeout}" 3 "${blurScript}" "$PPID" &
        disown
    '';

    mainConfig = pkgs.substituteAll {
        src = ./wezterm.lua;
        inherit blurScriptAsync;
        fish = lib.getExe pkgs.fish;
    };

in

{

    home.packages = with pkgs; [
        wezterm
    ];

    xdg.configFile = {
        "wezterm/wezterm.lua".source = mainConfig;
    };

}
