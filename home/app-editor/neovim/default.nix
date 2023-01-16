{ lib, pkgs, ... }:

let

  _ruby = pkgs.ruby-teapot.withPackages
    ( p: with p; [
      solargraph
      yard
    ] );

  extraPrograms = with pkgs; [
      fd ripgrep gcc
      nil
      _ruby
    ];

  _neovim =
    pkgs.neovim-teapot.override { inherit extraPrograms; };


in

{

  home.packages = [ _neovim ];

  home.sessionVariables.EDITOR =
    lib.mkOverride lib.nuranPrio "nvim";

}

