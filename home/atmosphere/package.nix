{ pkgs, ... }:

{ home.packages = with pkgs; [

  file ripgrep fd neofetch
  derputils
  wl-clipboard
  prime-offload

  p7zip
  rclone

  firefox_teapot
  virt-manager

]; programs = {

  zoxide.enable = true;

}; }
