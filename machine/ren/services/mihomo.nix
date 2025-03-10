{ config, pkgs, ... }:

let

    wpad = pkgs.writeTextDir "wpad.dat" /* javascript */ ''
        function FindProxyForURL( url, host ) {
            return "PROXY ren.home.lan:7890";
        }
    '';

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

    networking.firewall.allowedTCPPorts = [ 7890 ];
    networking.firewall.allowedUDPPorts = [ 7890 ];

    services.caddy.virtualHosts."http://wpad" = {
        listenAddresses = [ "[::]" ];
        logFormat = ''
            output stderr
        '';
        extraConfig = ''
            root * ${wpad}
            file_server browse
        '';
    };

}
