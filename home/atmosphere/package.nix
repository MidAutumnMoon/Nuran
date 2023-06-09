{ pkgs, ... }:

{ home.packages = with pkgs; [

  file ripgrep fd neofetch
  trurl
  derputils
  wl-clipboard
  prime-offload
  libtree
  lazygit
  libarchive
  nix-tree

  p7zip
  rclone
  pueue
  colmena_git

  firefox_teapot
  virt-manager

]; programs = {

  zoxide.enable = true;

}; }
