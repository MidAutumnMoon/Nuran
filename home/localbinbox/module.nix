# lny module — installs 7zz/jq/localbinbox; symlinks repo home/localbinbox/scripts -> $HOME/.local/bin
{ pkgs, dots, ... }:

{

    packages = with pkgs; [
        _7zip-zstd
        jq
        tsuki.localbinbox
    ];

    home.".local/bin".src = dots.get "localbinbox/scripts";

}
