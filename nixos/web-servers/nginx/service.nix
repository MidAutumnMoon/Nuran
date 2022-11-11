{ lib, config, pkgs, ... }:

let

  nginxCfg =
    config.nuran.nginx;

  nginxCmd =
    "${lib.getExe nginxCfg.package} -c ${nginxCfg.configFile}";

  serviceConfig = {
      ExecStart = nginxCmd;
      ExecReload =
        [ "${nginxCmd} -t"
          "${pkgs.coreutils}/bin/kill -HUP $MAINPID"
        ];
      Restart = "always";
      RestartSec = "10s";

      User = nginxCfg.account;
      Group = nginxCfg.account;
      SupplementaryGroups =
        [ config.users.groups."keys".name ];

      RuntimeDirectory = "nginx";
      RuntimeDirectoryMode = "0750";
      CacheDirectory = "nginx";
      CacheDirectoryMode = "0750";
      LogsDirectory = "nginx";
      LogsDirectoryMode = "0750";

      ProcSubset = "pid";
      UMask = "0027"; # 0640 / 0750

      AmbientCapabilities =
        [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];
      CapabilityBoundingSet =
        [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ];

      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies =
        [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      PrivateMounts = true;

      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
    };

in

lib.condMod (nginxCfg.enable) {

  systemd.services."nginx" =
    { description = "Nginx Web Server";
      wantedBy =
        [ "multi-user.target" ];
      after =
        [ "network.target" "nss-lookup.target" ];

      inherit serviceConfig;
    };

}
