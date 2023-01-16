{ lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

      dig mtr

      htop git screen
      file fd ripgrep

      neovim-teapot

    ];

  environment.variables.EDITOR =
    lib.mkOverride lib.nuranPrio "nvim";


  programs = {

      neovim.enable = lib.mkForce false;

      fish.enable = true;

      command-not-found.enable = false;

    };


  documentation.nixos.enable = false;

}
