{ pkgs, lib, ... }:

lib.mkMerge [

( let

    inherit ( lib ) getExe;

    inherit ( pkgs )
        copyPathToStore
        writeShellScript
        ;

    cage = getExe pkgs.cage;
    gtkgreet = getExe pkgs.gtkgreet_teapot;
    rnchoose = "${pkgs.derputils}/bin/rnchoose";

    pictures =
        pkgs.callPackage ./asset/picture.nix {};

    styleRandomPic = writeShellScript "greetd-style" ''
        declare -r \
            Picture="$( ${rnchoose} --stdin < "${pictures}" )"
        exec sed \
            "s|@picture@|$Picture|g" \
            "${copyPathToStore ./asset/style.css}"
    '';

    greetd-script = writeShellScript "greetd-script" ''
        exec '${cage}' -d -s -- '${gtkgreet}' \
            --style <( "${styleRandomPic}" ) \
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

            kate ark
            qimgv
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
