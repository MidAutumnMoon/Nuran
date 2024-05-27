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

]
