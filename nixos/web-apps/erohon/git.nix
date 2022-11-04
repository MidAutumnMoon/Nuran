{ lib, config, pkgs, ... }:

let

  cfg =
    config.nuran.services.erohon;

in

lib.condMod (cfg.enable) {

  users.groups."${cfg.account}" = {};

  users.users."${cfg.account}" =
    { home = cfg.repoPath;
      shell = "${pkgs.git}/bin/git-shell";
      group = "${cfg.account}";
      createHome = true;
      isSystemUser = true;
      openssh.authorizedKeys.keys =
        config.nudata.pubkeyList;
    };

  systemd.tmpfiles.rules =
    [ "L+ ${cfg.repoPath}/git-shell-commands - - - - ${cfg.maintenanceScripts}" ];

}
