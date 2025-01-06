{ lib, config, ... }:

let

    inherit ( lib )
        types
    ;

in {

    options.lore = {
        nuranDirPath = lib.mkOption {
            type = types.path;
            readOnly = true;
            default = "${config.home.homeDirectory}/Nuran";
        };
    };

}
