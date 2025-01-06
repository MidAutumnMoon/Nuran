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

    };

    home.file = {

        ".local/bin".source =
            mkOutOfStoreSymlink "${dotfiles}/bin";

    };

}
