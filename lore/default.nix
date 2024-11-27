{ lib, config, ... }:

let

    inherit (lib)
        types
    ;

in {

    imports = [
        ./certs
    ];

    options.lore.pubkeys = lib.mkOption {
        type = types.attrsOf types.str;
        readOnly = true;
    };

    options.lore.pubkeyList = lib.mkOption {
        type = types.listOf types.str;
        default = builtins.attrValues config.lore.pubkeys;
        readOnly = true;
    };

    config = {
        lore.pubkeys = {
            teapot = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEyX4qdUuwPEqQa+QaR8/0MubpfB9rHbpGAH+yEM9kxM me@418.im";
        };
    };

}

# vim: set nowrap:
