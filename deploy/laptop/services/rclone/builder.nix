{
  remoteName,
  mountPoint,
  configPath,
  extraFlags ? []
}:


{ lib, config, pkgs, ... }:

let

  inherit ( config.security ) wrapperDir;

  mountScript = ''
    ${lib.getExe pkgs.rclone} mount \
      --config '${configPath}' \
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
      ${toString extraFlags} \
      "${remoteName}:" '${mountPoint}'
    '';

  unmountScript = ''
    ${wrapperDir}/fusermount3 -u '${mountPoint}'
    '';

in

{ systemd.user.services."rclone-${remoteName}" = {

  description = "rclone mount for ${remoteName}";

  unitConfig = {
      AssertPathExists = [ configPath ];
      AssertPathIsDirectory = [ mountPoint ];
    };

  environment = config.networking.proxy.envVars;

  # `path` option append `/bin` and `/sbin` to
  # its values to construct $PATH, wtf
  path = [ ( builtins.dirOf wrapperDir ) ];

  serviceConfig = {
      Type = "notify";
      ExecStart = mountScript;
      ExecStop = unmountScript;
    };

  wantedBy = [ "default.target" ];

}; }

