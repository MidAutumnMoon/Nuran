{ lib, pkgs, ... }:

let

  inherit ( pkgs ) callPackage;

  readAllFish =
    callPackage ./read_all_fish.nix {};

in

lib.mkMerge [

{ programs.fish = {

  enable = true;

  shellInit = ''
    source "${ readAllFish ./global }"
    set --prepend fish_function_path \
      "${ callPackage ./functions/build.nix { inherit lib; } }"
  '';

  interactiveShellInit = ''
    source "${ readAllFish ./interactive }"
  '';

}; }


{ home.packages = with pkgs; [
  moreutils
  fishPlugins.tide
  fishPlugins.puffer-fish
]; }

]
