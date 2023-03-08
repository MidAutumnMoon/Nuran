{ pkgs, ... }:

{ environment.systemPackages = with pkgs; [

  dig mtr

  htop screen

  file
  fd ripgrep

  comma

]; }
