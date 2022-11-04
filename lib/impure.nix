let

  nixpkgs = import <nixos> {};

  lib = nixpkgs.lib.extend (import ./.);

in

  lib
