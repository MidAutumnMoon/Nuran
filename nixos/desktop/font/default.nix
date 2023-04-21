{ lib, config, pkgs, ... }:

lib.condMod ( config.fonts.fontconfig.enable )

{ fonts = {

  enableDefaultFonts = lib.mkForce false;

  fonts = with pkgs; [
    noto-fonts-cjk_teapot
    noto-fonts-emoji

    iosevka_teapot
    hack-font
    nerdfonts_teapot

    ibm-plex
  ];

  fontconfig = {

    defaultFonts = lib.mkForce {
      sansSerif =
        [ "Noto Sans" "Noto Sans CJK SC" ];
      serif =
        [ "Noto Sans" "Noto Sans CJK SC" ];
      monospace =
        [ "Hack" "Iosevka Teapot" ];
    };

    localConf = builtins.readFile ./local.xml;

    antialias = true;
    subpixel.rgba = "none";
    subpixel.lcdfilter = "none";

  };

}; }

