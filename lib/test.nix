with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

let

  isMDFile =
    path: if ( builtins.match ".*\\.md$" (toString path) ) != null then true else false;

in

filter isMDFile ( listAllFiles ./. )
