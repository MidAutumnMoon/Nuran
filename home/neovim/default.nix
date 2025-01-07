{ pkgs, ... }:

{

    home.packages = [ pkgs.neovim_teapot ];

    home.sessionVariables.EDITOR = "nvim";

}

