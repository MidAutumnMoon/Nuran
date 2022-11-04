{ lib, config, pkgs, ... }:


lib.condMod (config.nuran.fonts.enable) {

  options.nuran.fonts.enable =
    lib.mkEnableOption "Preferred fonts";


  fonts.enableDefaultFonts =
    lib.mkForce false;

  fonts.fonts = with pkgs;
    [ # CJK fonts
      source-han-sans

      # Sans & Monospace fonts
      iosevka-teapot
      (pkgs.nerdfonts.override {
        fonts = [ "Hack" ];
      })

      # Sans Serif fonts
      paratype-pt-sans

      # Emoji
      twemoji-color-font

      # All-in-one fonts
      ibm-plex
    ];

  fonts.fontconfig.defaultFonts = lib.mkForce
    { sansSerif =
        [ "PT Sans"
          "Source Han Sans SC"
          "Source Han Sans TC"
          "Source Han Sans"
        ];
      monospace =
        [ "Hack" ];
      emoji =
        [ "Twitter Color Emoji" ];
    };

  fonts.fontconfig.localConf =
    builtins.readFile ./local.xml;

  fonts.fontDir.enable = true;

}

