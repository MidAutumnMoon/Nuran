{ pkgs, ... }:

let

  extraPrograms = with pkgs;
    [
      fd ripgrep gcc
      nil
    ];

  usefulNeovim =
    pkgs.neovim_teapot.override { inherit extraPrograms; };


in

{

  home.packages = [ usefulNeovim ];

  home.sessionVariables.EDITOR = "nvim";

}

