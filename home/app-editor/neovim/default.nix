{ lib, pkgs, ... }:

let

  extraPrograms =
    with pkgs; [
      fd ripgrep gcc
      nil
    ];

  _neovim =
    pkgs.neovim_teapot.override { inherit extraPrograms; };


in

{

  home.packages = [ _neovim ];

  home.sessionVariables.EDITOR =
    lib.mkOverride lib.nuranPrio "nvim";

}

