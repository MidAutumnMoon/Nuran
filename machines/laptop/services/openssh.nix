{ lib, ... }:

{

  services.openssh.enable = true;

  services.openssh.openFirewall = false;

}
