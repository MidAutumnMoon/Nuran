{ lib, config, ... }:

lib.mkMerge [

{
    networking.useNetworkd = true;

    services.nscd.enableNsncd = true;
}


( let

    inherit ( config ) role nudata;

in {
    services.resolved.enable = true;

    services.resolved.extraConfig = if role.personal then ''
        Cache = no
    '' else ''
        DNSOverTLS = yes
    '';

    # Almost all clean foregin DoTs are blocked
    # by mainland china, DoH is the last resort.

    networking.nameservers = if role.personal then
        nudata.services.dns.listen
    else [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
    ];

} )


{ boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;
    "net.ipv4.tcp_notsent_lowat" = 16384;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
}; }

]
