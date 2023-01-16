{ lib, config, ... }:

lib.condMod (config.services.openssh.enable) {

  services.openssh.ports =
    lib.mkDefault [ 47128 ];

  services.openssh.openFirewall =
    lib.mkDefault true;

  services.openssh.settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

}

