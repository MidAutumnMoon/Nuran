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
        source ${./tide.fish}
    '';

    interactiveShellInit = ''
        source "${readAllFish ./init}"
    '';

}; }


{ home.packages = with pkgs; [
    moreutils
    fishPlugins.tide
    fishPlugins.puffer-fish
]; }

{
    programs.command-not-found.enable = false;
}

]
