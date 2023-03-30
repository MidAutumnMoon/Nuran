{ lib, ... }:

lib.mergeMod [

{
  networking.firewall.enable = true;

  networking.useNetworkd = true;

  services.resolved.enable = true;
}

{ boot.kernel.sysctl = {

  "net.ipv4.tcp_congestion_control" = "bbr";

  "net.ipv4.udp_rmem_min" = 8192;

  "net.ipv4.udp_wmem_min" = 8192;

}; }

]
