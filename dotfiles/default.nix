{ config, lib, ... }:

let

    inherit ( config.lib.file )
        mkOutOfStoreSymlink
    ;

    inherit ( config.lore )
        nuranDirPath
    ;

    dotfiles = "${nuranDirPath}/dotfiles";

in {

    xdg.configFile = {

        "rubocop/config.yml".source =
            mkOutOfStoreSymlink "${nuranDirPath}/.rubocop.yml";

        "nvim".source =
            mkOutOfStoreSymlink "${dotfiles}/neovim";

        "rclone/rclone.conf".source =
            mkOutOfStoreSymlink "/etc/rclone.conf";

        "irb/irbrc".text = /* ruby */ ''
            begin
                require "amazing_print"
                AmazingPrint.irb!
            rescue LoadError
                warn "Can't load amazing_print"
            end
        '';

    };

    home.file = {

        ".local/bin".source =
            mkOutOfStoreSymlink "${dotfiles}/bin";

    };

}
