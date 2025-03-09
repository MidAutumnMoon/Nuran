{ lib, config, ... }:

{

    users.mutableUsers = lib.mkForce false;

    sops.secrets."root_passwd" = {
        sopsFile = ./passwd.sops.yml;
        neededForUsers = true;
    };

    users.users."root" = with config; {
        hashedPasswordFile = sops.secrets."root_passwd".path;
        openssh.authorizedKeys.keys = [ lore.pubkeys.teapot ];
    };

}
