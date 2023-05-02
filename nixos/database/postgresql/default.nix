{ lib, config, pkgs, ... }:

lib.condMod config.services.postgresql.enable {

  services.postgresql.package = pkgs.postgresql_14;

  systemd.services.postgresql.serviceConfig = {
    PrivateDevices = true;
    PrivateTmp = true;

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];

    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

}
