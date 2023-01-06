{ lib, config, ... }:

lib.condMod (config.programs.direnv.enable) {

  programs.direnv.nix-direnv.enable = true;

}

