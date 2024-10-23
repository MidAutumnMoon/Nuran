{ lib, config, ... }:

{

  services.coredns.enable = true;

  services.coredns.config = ''
    .:53 {
      bind ${lib.elemAt config.networking.nameservers 0}

      log
      loadbalance

      cache 3600 {
        prefetch 1200 1m 30%
      }

      forward . tls://1.1.1.1 tls://1.0.0.1 {
        tls_servername cloudflare-dns.com
      }
    }
  '';

}
