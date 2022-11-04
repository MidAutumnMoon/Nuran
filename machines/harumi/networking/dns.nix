{ lib, ... }:

{

  networking.nameservers =
    lib.mkForce [ "1.1.1.1#cloudflare-dns.com" ];

  services.resolved.enable = true;

  services.resolved.extraConfig = ''
      DNSOverTLS = yes
    '';

}
