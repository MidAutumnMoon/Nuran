{ lib, ... }:

{

  services.logrotate.enable =
    lib.mkForce false;

  services.vnstat.enable = true;

  services.openssh.enable = true;

}
