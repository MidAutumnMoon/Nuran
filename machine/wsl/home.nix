{ lib, pkgs, ... }:

lib.mkMerge [

{ home = {

    packages = with pkgs; [
        rust-analyzer_teapot
        ruby_teapot.for_dev
        nixd
        luajit
        nixos-rebuild
        colmena
    ];

    username = "teapot";
    homeDirectory = "/home/teapot";

    stateVersion = "24.11";

}; }

{ programs.fish = {

    interactiveShellInit = ''
        # To make Windows Terminal open new tabs
        # with the same path of current one.
        function __windows_terminal --on-variable PWD
            set -q WT_SESSION
            and printf "\e]9;9;%s\e\\" ( wslpath -w "$PWD" )
        end
    '';

    # Vanilla open doesn't try wsl-open
    functions."open" = ''
        wsl-open $argv
    '';

    shellAbbrs = {
        "ru" = "paru";
        "d" = "deno";
        "b" = "bundle";
    };

}; }

]
