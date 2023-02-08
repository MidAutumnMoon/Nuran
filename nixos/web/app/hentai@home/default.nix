{ lib, config, pkgs, ... }:

let

  cfg =
    config.nuran.services.hentai-home;

in

lib.condMod (cfg.enable) {

  # Options

  options.nuran.services.hentai-home = {

    enable =
      lib.mkEnableOption "the gate to the wonderland";

    dataDir =
      lib.mkOption { type = lib.types.str; };

    port =
      lib.mkOption { type = lib.types.port; };

    account = lib.mkOption
      { type = lib.types.str;
        readOnly = true;
        default = "hentaihome";
      };

  };


  # Configs

  users.groups.${cfg.account} = {};

  users.users.${cfg.account} = {
      isSystemUser = true;
      group = cfg.account;
      home = cfg.dataDir;
      createHome = true;
    };

  networking.firewall.allowedTCPPorts =
    [ cfg.port ];


  systemd.services."hentai-home" =
    { description = "Hentai@Home";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
    };

  systemd.services."hentai-home".serviceConfig = {
      User = cfg.account;
      Group = cfg.account;
      Restart = "on-failure";
      RestartSec = "5s";

      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${lib.getExe pkgs.hentai-home}";
      WorkingDirectory = cfg.dataDir;

      RemoveIPC = true;
      NoNewPrivileges = true;
      LockPersonality = true;
      ProcSubset = "pid";
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectControlGroups = true;
      ProtectClock = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      SystemCallFilter = "@system-service";

      ReadOnlyPaths =
        [ "/nix/store"
          "/etc/ssl"
          "/etc/resolv.conf"
        ];
      ReadWritePaths =
        [ cfg.dataDir ];
    };

}
