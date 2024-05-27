{ pkgs, ... }:

let

    nvim = with pkgs;
        neovim_teapot.override {
            # TODO: gcc for compiling tree-sitter is
            # left out on purpose
            tools = [ fd ripgrep nil ];
        };

in

{

    home.packages = [ nvim ];

    home.sessionVariables.EDITOR = "nvim";

}

