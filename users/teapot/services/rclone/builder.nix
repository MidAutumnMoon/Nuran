{
  remoteName
, mountPoint
, configPath
, extraFlags ? ""
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
      --vfs-cache-mode full \
      --vfs-cache-max-size 2G \
      --vfs-cache-max-age 1m \
      --vfs-write-back 2s \
      --vfs-read-chunk-size 64M \
      --dir-cache-time 1m \
      --poll-interval 10s \
      --multi-thread-cutoff 64M \
      --multi-thread-streams 8 \
      --no-modtime \
      ${extraFlags} \
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
