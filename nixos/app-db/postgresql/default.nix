{ lib, config, pkgs, ... }:

lib.condMod config.services.postgresql.enable {

  services.postgresql.package =
    pkgs.postgresql_15;

  systemd.services.postgresql.serviceConfig = {
      RemoveIPC = true;
      NoNewPrivileges = true;

      PrivateDevices = true;
      PrivateTmp = true;

      ProtectSystem = "strict";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      ProtectHome = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      MemoryDenyWriteExecute = true;
      LockPersonality = true;

      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      RestrictAddressFamilies =
        [ "AF_UNIX" "AF_INET" "AF_INET6" ];

      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };

}
