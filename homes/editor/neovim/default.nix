{ lib, config, pkgs, ... }:

let

  _neovim = pkgs.neovim-teapot.override
    { extraTools = with pkgs; [
        fd
        gcc
        nil
        rubyPackages_3.solargraph
      ]; };


in

lib.condMod (config.programs.neovim.enable) {

  disabledModules =
    [ "programs/neovim.nix" ];

  options.programs.neovim = lib.mkOption {
      type = lib.types.submodule
        { freeformType = with lib.types;
            attrsOf anything;
          options.enable =
            lib.mkEnableOption "Numinus!";
        };
    };

  home.packages =
    [ _neovim ];

}

