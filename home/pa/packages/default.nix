{ pkgs, ... }:

{ home.packages = with pkgs; [

    file
    ripgrep fd fastfetch

    libtree
    nix-tree

    unrar
    rclone

]; }
