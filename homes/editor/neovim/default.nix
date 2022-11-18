{ lib, config, pkgs, ... }:

let

  localRuby = pkgs.ruby-teapot.withPackages ( p: with p; [
      solargraph
      yard
    ] );

  extraTools = with pkgs; [
      fd ripgrep gcc
      nil
      localRuby
    ];

  localNeovim =
    pkgs.neovim-teapot.override { inherit extraTools; };


in

lib.condMod (config.programs.neovim.enable) {

  disabledModules = [
      "programs/neovim.nix"
    ];

  options.programs.neovim = lib.mkOption {
      type = lib.types.submodule
        { freeformType = with lib.types;
            attrsOf anything;
          options.enable =
            lib.mkEnableOption "Numinus!";
        };
    };

  home.packages = [
      localNeovim
    ];

}

