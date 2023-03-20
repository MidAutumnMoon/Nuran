{ lib, config, pkgs, ... }:

lib.condMod ( config.fonts.fontconfig.enable ) {

  fonts.enableDefaultFonts =
    lib.mkForce false;

  fonts.fonts = with pkgs; [
      noto-fonts-cjk_teapot

      iosevka_teapot
      hack-font
      nerdfonts_teapot

      ibm-plex
    ];

  fonts.fontconfig.defaultFonts = lib.mkForce {
      sansSerif =
        [ "Noto Sans" "Noto Sans CJK SC" ];
      serif =
        [ "Noto Sans" "Noto Sans CJK SC" ];
      monospace =
        [ "Hack" "Iosevka Teapot" ];
      emoji = [];
    };

  fonts.fontconfig.localConf =
    builtins.readFile ./local.xml;


  fonts.fontconfig.antialias = true;

  fonts.fontconfig.subpixel.rgba = "none";

  fonts.fontconfig.subpixel.lcdfilter = "none";

}

