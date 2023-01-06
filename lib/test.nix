with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

length (listAllDirs /home/teapot/Playground/nixpkgs)
