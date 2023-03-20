{ pkgs, ... }:

let

  readAllFish =
    pkgs.callPackage ./read_all_fish.nix {};

  buildFunctions =
    pkgs.callPackage ./build_functions.nix {};

in

{

  programs.fish.enable = true;

  programs.fish.shellInit = ''
    source "${ readAllFish ./global }"

    set --prepend fish_function_path \
      ${ buildFunctions ./functions }
    '';


  programs.fish.interactiveShellInit = ''
    source "${ readAllFish ./interactive }"
    '';


  home.packages = with pkgs; [
      moreutils
      fishPlugins.tide
      fishPlugins.puffer-fish
    ];


}

