{ lib, ... }:

let

  inherit ( lib ) mkDefault;

in

lib.mkMerge [

{ services.openssh = {

  enable = true;
  ports = mkDefault [ 47128 ];
  openFirewall = mkDefault true;

}; }

{ services.openssh.settings = {

  PermitRootLogin = "prohibit-password";
  PasswordAuthentication = false;
  KbdInteractiveAuthentication = false;

}; }

]

