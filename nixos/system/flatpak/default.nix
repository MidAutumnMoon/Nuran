{ lib, config, ... }:

let

  dataHome = "%h/.local/share";

  systemData = "/run/current-system/sw/share";

in

lib.condMod ( config.services.flatpak.enable ) {

  fonts.fontDir.enable = true;

  systemd.user.tmpfiles.rules = [
      "L ${dataHome}/fonts - - - - ${systemData}/X11/fonts"
      "L ${dataHome}/icons - - - - ${systemData}/icons"
    ];

}
