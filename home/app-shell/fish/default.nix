{ lib, config, pkgs, ... }:

lib.condMod (config.programs.fish.enable) {

  programs.fish.shellInit = ''
    source "${ pkgs.callPackage ./read-files.nix { toplevel = ./init; } }"
    set --prepend fish_function_path \
      ${ pkgs.callPackage ./normalize-functions.nix {} }
    '';

  programs.fish.interactiveShellInit = ''
    source "${ pkgs.callPackage ./read-files.nix { toplevel = ./config; } }"
    '';

  home.packages = with pkgs; with fishPlugins;
    [ moreutils
      tide
      puffer-fish
    ];

}

