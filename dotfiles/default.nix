{ config, lib, pkgs, ... }:

let

    inherit ( config.lib.file )
        mkOutOfStoreSymlink
    ;

    inherit ( config.lore )
        nuranDirPath
    ;

    dotfiles = "${nuranDirPath}/dotfiles";

in {

    home.packages = with pkgs; [
        _7zz
        par2cmdline-turbo
        jq
    ];

    xdg.configFile = {

        "irb/irbrc".text = /* ruby */ ''
            begin
                require "amazing_print"
                AmazingPrint.irb!
            rescue LoadError
                warn "Can't load amazing_print"
            end
        '';

        "rubocop/config.yml".source =
            mkOutOfStoreSymlink "${nuranDirPath}/.rubocop.yml";

        "nvim".source =
            mkOutOfStoreSymlink "${dotfiles}/neovim";

        "rclone/rclone.conf".source =
            mkOutOfStoreSymlink "/etc/rclone.conf";

        "gallery-dl/config.json".source =
            mkOutOfStoreSymlink "${dotfiles}/gallery-dl/config.json";

    };

    home.file = {

        ".local/bin".source =
            mkOutOfStoreSymlink "${dotfiles}/bin";

    };

}
