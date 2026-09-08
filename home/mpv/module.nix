# lny module — installs mpv; symlinks repo home/mpv (dir) -> $XDG_CONFIG_HOME/mpv
{ dots, pkgs, ... }:

{

    packages = with pkgs; [
        mpv
        mpvScripts.mpris
    ];

    xdg_config."mpv".src = dots.get "mpv";

}
