{ pkgs, ... }:

let

    nvim = with pkgs;
        neovim_teapot.override {
            tools = [ fd ripgrep ];
        };

in

{

    home.packages = [ nvim ];

    home.sessionVariables.EDITOR = "nvim";

}

