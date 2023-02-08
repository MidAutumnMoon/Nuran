{ lib, ... }:

{ programs = {

  neovim.enable = lib.mkForce false;

  fish.enable = true;

  command-not-found.enable = false;

}; }
