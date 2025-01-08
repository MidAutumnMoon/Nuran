{ lib, pkgs, ... }:

let

    selfUsername = "teapot";

in {

    imports = [
        ./rclone
    ];

    home-manager.users.${selfUsername} = import ./home.nix;

    wsl = {
        enable = true;
        defaultUser = selfUsername;

        wslConf = {
            user.default = selfUsername;
            network.generateResolvConf = false;
        };

        interop = {
            includePath = false;
        };
    };

    programs = {
        fish.enable = true;
    };

    fileSystems."/mnt/z" = {
        device = "Z:";
        fsType = "drvfs";
        options = [ "defaults" "async" "noatime" "metadata" "nofail" ];
    };

    networking = {
        hostName = "loonie";
        useDHCP = false;

        # WSL kernel doesn't come with necessary module to run nftables,
        # besides, Windows already has firewall configured anyway.
        firewall.enable = lib.mkForce false;

        proxy.default = "http://127.0.0.1:7890";

        nameservers = [ "10.0.1.1" ];
    };

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

}
