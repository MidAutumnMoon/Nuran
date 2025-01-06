{ lib, pkgs, ... }:

let

    readAllFish =
        pkgs.callPackage ./read_all_fish.nix {};

    functions =
        pkgs.callPackage ./functions/build.nix { inherit lib; };

in

lib.mkMerge [

{ programs.fish = {

    enable = true;

    shellInit = ''
        functions --erase ll
        functions --erase la
        set --prepend fish_function_path "${functions}"
    '';

    interactiveShellInit = ''
        source ${./tide.fish}
        source "${readAllFish ./init}"
    '';

}; }

{
    programs.command-not-found.enable = false;
}

]
