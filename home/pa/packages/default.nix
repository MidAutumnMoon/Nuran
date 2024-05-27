{ pkgs, ... }:

{ home.packages = with pkgs; [

    file
    ripgrep fd fastfetch

    libtree
    nix-tree

    p7zip unrar
    rclone

]; }
