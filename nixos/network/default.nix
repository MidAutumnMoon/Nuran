{

    networking ={
        useNetworkd = true;
        firewall.enable = true;
    };

    services.resolved.enable = true;

    boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_notsent_lowat" = 16384;
        "net.ipv4.tcp_slow_start_after_idle" = 0;
        "net.ipv4.tcp_no_metrics_save" = 0;
        "net.core.rmem_max" = 67108864;
        "net.core.wmem_max" = 67108864;
        "net.ipv4.tcp_mtu_probing" = 1;
    };

}
