{ lib, pkgs, ... }:

let

    selfUsername = "teapot";

in {

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

    networking = {
        hostName = "loonie";
        useDHCP = false;

        # WSL kernel doesn't come with necessary module to run nftables,
        # besides, Windows already has firewall configured anyway.
        firewall.enable = lib.mkForce false;

        proxy.default = "http://172.28.240.1:7890";
    };

    home-manager.users.${selfUsername} = import ./home;

    environment.systemPackages = [ pkgs.git pkgs.gcc pkgs.nixd ];

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

}
