{

  networking.firewall.enable = true;

  boot.kernel.sysctl = {
      "net.core.default_qdisc" =
        "fq_pie";
      "net.ipv4.tcp_congestion_control" =
        "bbr";
      "net.core.rmem_max" =
        2500000;
      "net.core.netdev_max_backlog" =
        10000;
      "net.ipv4.udp_rmem_min" =
        8192;
      "net.ipv4.udp_wmem_min" =
        8192;
      "net.ipv4.tcp_slow_start_after_idle" =
        0;
    };

  networking.useNetworkd = true;

  services.resolved.enable = true;

}
