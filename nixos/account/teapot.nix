{ config, lib, ... }:

let

    name = "teapot";

in

lib.mkMerge [

{ users.users.${name}= {

    inherit ( config.users.users."root" )
        hashedPassword;

    isNormalUser = true;

    description = "MidAutumnMoon";

    extraGroups = [
        "wheel"
        config.users.groups."keys".name
    ];

}; }

{
    security.sudo.wheelNeedsPassword = false;

    nix.settings.trusted-users = [ name ];

    home-manager.users.${name}= {};
}

]
