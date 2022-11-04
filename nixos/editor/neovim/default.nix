{ lib, config, pkgs, ... }:


lib.condMod (config.programs.neovim.enable) {

  disabledModules =
    [ "programs/neovim.nix" ];

  options.programs.neovim.enable =
    lib.mkEnableOption "Numinus";


  environment.systemPackages = with pkgs;
    [ neovim-teapot-with-config ];

  environment.variables.EDITOR =
    lib.mkOverride 900 "nvim";

}
