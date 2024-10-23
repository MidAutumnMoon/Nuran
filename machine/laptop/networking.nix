{ lib, pkgs, config, ... }:

lib.mkMerge [

{ networking = {

    hostName = "reuuko";

    networkmanager = {
        enable = true;
        plugins = lib.mkForce [];
        wifi.backend = "iwd";
    };

    proxy = {
        default = "http://127.0.0.1:1082";
        noProxy = "127.0.0.1,localhost";
    };

    firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp \
            --src 192.168.50.0/24,192.168.122.1/24 \
            --match multiport \
                --dports 1081,1082,8080:8090 \
            --jump nixos-fw-accept
    '';

}; }

{
    services.usbmuxd.enable = true;

    environment.systemPackages = [
        pkgs.libimobiledevice
    ];

    systemd.services.ModemManager.enable = false;
}

{
    systemd.network.wait-online.extraArgs = [
        "--interface=wlp2s0:routable"
    ];
}

]
