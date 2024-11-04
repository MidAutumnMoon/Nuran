{ lib, config, ... }:

let

    inherit (lib)
        types
    ;

in {

    imports = [
        ./pubkeys.nix
        ./certs
    ];

    options.nudata.pubkeys = lib.mkOption {
        type = types.attrsOf types.str;
        readOnly = true;
    };

    options.nudata.pubkeyList = lib.mkOption {
        type = types.listOf types.str;
        default = builtins.attrValues config.nudata.pubkeys;
        readOnly = true;
    };

}
