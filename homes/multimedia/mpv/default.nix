{ lib, config, pkgs, ... }:

lib.condMod (config.programs.mpv.enable) {

  programs.mpv.package = pkgs.mpv-teapot;

  programs.mpv.bindings =
    import ./input.nix;

}
