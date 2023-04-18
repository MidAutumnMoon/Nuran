with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in


filter (hasExtension ".nix") ( listAllFiles ./. )
