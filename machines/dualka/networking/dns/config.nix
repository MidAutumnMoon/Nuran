{ lib, ... }:

{

  networking.nameservers =
    lib.mkForce [ "127.0.10.53" ];

  services.resolved.enable = true;

  services.resolved.extraConfig = ''
    Cache = no
    FallbackDNS =
    LLMNR = no
  '';

}
