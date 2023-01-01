{ lib, config, ... }:

lib.condMod (config.programs.direnv.enable) {

  programs.direnv =
    { enableBashIntegration = true;
      nix-direnv.enable = true;
    };

}

