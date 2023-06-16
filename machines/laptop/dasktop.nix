{ pkgs, lib, ... }:

lib.mkMerge [

( let

    inherit ( lib ) getExe ;

    cage = getExe pkgs.cage;
    gtkgreet = getExe pkgs.gtkgreet_teapot;

    picture = pkgs.fetchurl {
        url = "https://p.418.im/4ee3cc3c6939fdff.jpg";
        hash = "sha256-70NDsdm75C34QYXD5rv3of8JVLJeBZw0n0PVODksXPg=";
    };

    style = pkgs.substituteAll {
        src = ./asset/style.css;
        inherit picture;
    };

    greetd-script = pkgs.writeShellScript "greetd-script" ''
        exec '${cage}' -d -s -- '${gtkgreet}' \
            --style '${style}' \
            --command startplasma-wayland
     '';

in {

    services.greetd = {
        settings = {
            default_session.command = greetd-script;
        };
        enable = true;
    };


    security.pam.services.greetd.enableKwallet = true;

    systemd.services.greetd.serviceConfig = {
        # "idle" slows down the login flow a lot
        Type = lib.mkForce "simple";
    };

} )

{

    programs.dconf.enable = true;

    programs.ssh.enableAskPassword = false;

    services.xserver.desktopManager.plasma5 = {
        enable = true;
        runUsingSystemd = true;
        phononBackend = "vlc";
    };

    environment.systemPackages =
        with pkgs;
        with plasma5Packages;
        with kdeGear;
        [
            kde-gtk-config
            fcitx5-qt

            papirus-icon-theme
            graphite-cursor-theme
            breeze-gtk

            unzip unrar
            kate ark
            qimgv

            xorg.xprop
            xdg-utils
        ];

}

{ i18n.inputMethod = {

    enabled = "fcitx5";

    fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chinese-addons
    ];

}; }

]
