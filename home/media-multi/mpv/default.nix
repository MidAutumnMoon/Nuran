{ lib, config, pkgs, ... }:

lib.condMod (config.programs.mpv.enable) {

  programs.mpv.package = pkgs.mpv-teapot;

  programs.mpv.bindings =
    import ./binding.nix;

  xdg.configFile."mpv/mpv.conf".source = ./mpv.conf;

}
