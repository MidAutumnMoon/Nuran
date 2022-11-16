{
  remoteName
, mountPoint
, configPath
, extraFlags ? []
}:


{ lib, config, pkgs, nixosConfig, ... }:

let

  inherit (nixosConfig.security) wrapperDir;

  fusermount3Path =
    wrapperDir + "/fusermount3";

  proxyEnv =
    nixosConfig.networking.proxy.envVars;

  proxyEnvList =
    lib.attrValues ( lib.mapAttrs (n: v: "${n}=${v}") proxyEnv );

  pathEnvList =
    [ "PATH=${wrapperDir}:${pkgs.coreutils}/bin" ];

  startScript = ''
    ${lib.getExe pkgs.rclone} mount \
      --config ${configPath} \
      --log-level INFO \
      --log-systemd \
      --human-readable \
      --max-backlog -1 \
      --fast-list \
      --use-mmap \
      --expect-continue-timeout 0 \
      --disable-http2 \
      --vfs-cache-mode full \
      --vfs-cache-max-size 8G \
      --vfs-cache-max-age 1h \
      --dir-cache-time 1m \
      --poll-interval 10s \
      --multi-thread-cutoff 128M \
      --multi-thread-streams 8 \
      ${lib.concatStringsSep " " extraFlags} \
      "${remoteName}:" "${mountPoint}"
    '';

in

{ systemd.user.services."rclone-${remoteName}" = {

  Unit = {
      Description = "rclone mount for ${remoteName}";
      AssertPathIsDirectory = [ mountPoint ];
      AssertPathExists = [ configPath ];
    };

  Service = {
      Type = "notify";
      Environment = proxyEnvList ++ pathEnvList;
      ExecStart = startScript;
      ExecStop = "${fusermount3Path} -u ${mountPoint}";
      Restart = "on-failure";
    };

  Install.WantedBy = [ "default.target" ];

}; }
