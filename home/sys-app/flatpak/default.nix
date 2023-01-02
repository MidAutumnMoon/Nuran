{ config, ... }:

let

  inherit ( config.xdg ) dataHome;

in

{

  # flatpak override --user --filesystem=/nix/store
  systemd.user.tmpfiles.rules = [
      "L ${ dataHome }/fonts - - - - /run/current-system/sw/share/X11/fonts"
      "L ${ dataHome }/icons - - - - /run/current-system/sw/share/icons"
    ];

}
