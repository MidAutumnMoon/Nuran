with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

let

  pkgsBrew = brewNixpkgs { inherit someting; };

in

pkgsBrew."<system>".any

pkgsBrew ( p: with p; [ hello ] )
