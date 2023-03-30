{ lib, ... }:

{ services = {

  logrotate.enable = lib.mkForce false;

  vnstat.enable = true;

}; }
