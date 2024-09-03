{ lib, pkgs, ... }:

lib.mkMerge [

{ home = {

    packages = with pkgs; [
        # Some tools
        rust-analyzer_teapot
        ruby_teapot.brewed
        ( lib.hiPrio ruby_teapot.for_dev )
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
        "p" = "pnpm";
        "d" = "deno";
    };

}; }

]
