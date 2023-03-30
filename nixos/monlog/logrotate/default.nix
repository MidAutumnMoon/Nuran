{ lib, ... }:

{

  services.logrotate.enable = lib.mkForce false;

}
