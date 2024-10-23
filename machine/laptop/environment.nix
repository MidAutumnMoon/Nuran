{ lib, ... }:

lib.mkMerge [

{ sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
]; }

{ environment.persistence."/persist" = {
    hideMounts = true;
}; }

{ environment.persistence."/persist".users."teapot" = {
    directories = [
        { directory = ".ssh"; mode = "0700"; }
    ];
    files = [];
}; }

]
