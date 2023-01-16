{ lib, config, pkgs, ... }:

lib.condMod ( config.fonts.fontconfig.enable ) {

  fonts.enableDefaultFonts =
    lib.mkForce false;

  fonts.fonts = with pkgs; [
      noto-fonts-cjk-teapot

      iosevka-teapot
      hack-font
      nerdfonts-teapot

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


  fonts.fontconfig.hinting = lib.mkDefault {
      enable = true;
      autohint = true;
    };

  fonts.fontconfig.antialias =
    lib.mkDefault true;

  fonts.fontconfig.subpixel.rgba = "none";

  fonts.fontconfig.subpixel.lcdfilter = "none";


  fonts.fontDir.enable = true;

}

