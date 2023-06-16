{ lib, config, pkgs, ... }:

lib.condMod ( config.fonts.fontconfig.enable )

( lib.mkMerge [

{ fonts = {

    enableDefaultFonts = lib.mkForce false;

    fonts = with pkgs; [
        noto-fonts
        source-han-sans
        noto-fonts-emoji

        iosevka_teapot
        hack-font

        ibm-plex
    ];

}; }

{ fonts.fontconfig = {

    defaultFonts = lib.mkForce {
        sansSerif = [
            "Noto Sans"
            "Source Han Sans SC"
        ];
        serif = [
            "Noto Sans"
            "Source Han Sans SC"
        ];
        monospace = [
            "Hack"
            "Source Han Sans SC"
        ];
    };

    localConf = builtins.readFile ./local.xml;

    antialias = true;
    subpixel.rgba = "none";
    subpixel.lcdfilter = "none";

}; }

{ systemd.user.tmpfiles.rules = [

    "R! %h/.cache/fontconfig - - - 0 -"
    "R! %h/.var/app/**/cache/fontconfig - - - 0 -"

]; }

] )
