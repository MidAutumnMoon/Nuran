{ lib, config, ... }:

lib.mkMerge [


{ services.adguardhome = {
    enable = true;
    mutableSettings = true;
    host = "127.0.0.1";
    port = 10100;
}; }


{ services.adguardhome.settings = {

    filters = [
        {
            enabled = true;
            url = "https://ruleset.skk.moe/Internal/reject-adguardhome.txt";
            name = "skk ruleset";
            id = 101;
        }
    ];

    dns.upstream_dns = [
        "[//]udp://10.0.1.1:53"
        "[/lan/]udp://10.0.1.1:53"
        "quic://dns.alidns.com:853"
    ];

    dns.allowed_clients = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "fc00::/7"
        "fe80::/10"
    ];

}; }


{ services.caddy.virtualHosts."home_lan" = let
    inherit ( config.services.adguardhome )
        port
        host
    ;
in {
    extraConfig = ''
        @adguardhome host dns.home.lan
        handle @adguardhome {
            reverse_proxy http://${host}:${toString port}
        }
    '';
};}

{
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
}


]
