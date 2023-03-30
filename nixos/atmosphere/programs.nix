{ lib, pkgs, ... }:

{ programs = {

  neovim.enable = lib.mkForce false;

  fish.enable = true;

  command-not-found.enable = false;

}; environment.systemPackages = with pkgs; [

  dig mtr

  htop screen

  file
  fd ripgrep

  comma

]; }
