{ lib, config, ... }:

lib.mkMerge [

{
  networking.useNetworkd = true;

  services.nscd.enableNsncd = true;
}

{
  networking.nameservers =
    lib.attrValues config.nudata.services.dnscrypt;

  services.resolved.enable = true;

  services.resolved.extraConfig = ''
    Cache = no
    '';
}

{ boot.kernel.sysctl = {

  "net.core.default_qdisc" = "fq";

  "net.ipv4.tcp_congestion_control" = "bbr";

  "net.ipv4.udp_rmem_min" = 8192;

  "net.ipv4.udp_wmem_min" = 8192;

  "net.ipv4.tcp_notsent_lowat" = 16384;

  "net.ipv4.tcp_slow_start_after_idle" = 0;

}; }

]
