{ lib, config, ... }:

lib.condMod (config.programs.mpv.enable) {

  programs.mpv.bindings =
    import ./input.nix;

}
