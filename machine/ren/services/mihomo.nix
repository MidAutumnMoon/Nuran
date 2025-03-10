{ config, pkgs, ... }:

let

    listenPort = 7890;
    apiPort = 7895;

in

{

    # N.B. assume /run/secrets/cert--hysteria_ca exists
    sops.secrets = let
        restartUnits = [ "mihomo.service" ];
    in {
        "conf--mihomo" = {
            sopsFile = ./secrets/conf--mihomo.sops.data;
            format = "binary";
            inherit restartUnits;
        };
        "cert--hysteria_ca" = {
            sopsFile = ./secrets/cert--hysteria_ca.sops.yml;
            inherit restartUnits;
        };
    };

    services.mihomo = {
        enable = true;
        configFile = config.sops.secrets."conf--mihomo".path;
    };

    systemd.services."mihomo" = {
        serviceConfig.LoadCredential = [
            "cert--hysteria_ca:${config.sops.secrets.cert--hysteria_ca.path}"
        ];
    };

    networking.firewall.allowedTCPPorts = [ listenPort ];
    networking.firewall.allowedUDPPorts = [ listenPort ];

    services.caddy.virtualHosts."http://wpad" = let
        wpad = pkgs.writeTextDir "wpad.dat"
            /* javascript */ ''
                function FindProxyForURL( url, host ) {
                    return "PROXY ren.home.lan:${toString listenPort}";
                }
            '';
    in {
        listenAddresses = [ "[::]" ];
        logFormat = ''
            output stderr
        '';
        extraConfig = ''
            root * ${wpad}
            file_server browse
        '';
    };

    services.caddy.virtualHosts."*.home.lan" = {
        extraConfig = ''
            @mihomo host clash.home.lan
            handle @mihomo {
                handle_path /api* {
                    reverse_proxy 127.0.0.1:${toString apiPort}
                }
                root * ${pkgs.metacubexd}
                file_server
            }
        '';
    };

}
