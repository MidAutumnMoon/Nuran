{ pkgs, ... }:

{ home.packages = with pkgs; [

  file ripgrep fd neofetch
  trurl
  derputils
  wl-clipboard
  prime-offload

  p7zip
  rclone
  pueue
  colmena_git

  firefox_teapot
  virt-manager

]; programs = {

  zoxide.enable = true;

}; }
