{ lib, config, ... }:

lib.condMod (config.programs.gpg.enable) {

  imports =
    [ ./agent.nix ];

  programs.gpg.homedir =
    "${config.xdg.dataHome}/gnupg";

}
