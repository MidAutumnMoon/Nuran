{ lib, config, ... }:

{

  imports =
    [ ./agent.nix ];

  programs.gpg.enable = true;

  programs.gpg.homedir =
    "${config.xdg.dataHome}/gnupg";

}
