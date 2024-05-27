{ lib, pkgs, ... }:

lib.mkMerge [

{ home = {

    packages = with pkgs; [
        home-manager

        # Some tools
        rust-analyzer_teapot
    ];

    username = "teapot";
    homeDirectory = "/home/teapot";

    stateVersion = "24.11";

}; }

{ programs.fish = {

    interactiveShellInit = ''
        function __windows_terminal --on-variable PWD
            set -q WT_SESSION
            and printf "\e]9;9;%s\e\\" ( wslpath -w "$PWD" )
        end
    '';

    shellAbbrs = {
        "ru" = "paru";
    };

}; }

]
