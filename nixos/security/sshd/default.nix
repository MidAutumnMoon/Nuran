{ lib, config, ... }:

lib.condMod (config.services.openssh.enable) {

  services.openssh.ports =
    lib.mkDefault [ 47128 ];

  services.openssh.openFirewall =
    lib.mkDefault true;

  services.openssh =
    { permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };

}

