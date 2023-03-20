{ config, ... }:

let

  inherit ( config.home ) homeDirectory;

in

{ home.sessionVariables = {

  NIXPKGS_ALLOW_UNFREE = 1;

  Nuran = "${homeDirectory}/Nix";

}; }
