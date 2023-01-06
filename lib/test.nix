with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

isModule ./.
