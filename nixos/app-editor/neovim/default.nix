{ lib, config, pkgs, ... }:


lib.condMod (config.programs.neovim.enable) {

  programs.neovim = {

      package =
        pkgs.neovim-unwrapped-teapot;

      withRuby = false;

      withPython3 = false;

      withNodeJs = false;

      defaultEditor = true;

    };

}
