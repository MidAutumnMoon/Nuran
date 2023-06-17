with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in


capitalize "hello string"
