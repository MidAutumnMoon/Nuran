{ lib, ... }:

{ services.openssh = {

    enable = true;

    ports = lib.mkDefault [ 47128 ];
    openFirewall = lib.mkDefault true;

    settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
    };

}; }

