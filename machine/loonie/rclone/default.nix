{ config, lib, pkgs, ... }:

{

    sops.secrets."rclone_conf".sopsFile =
        ./rclone_conf.sops.yml
    ;

    environment.etc."rclone.conf" = {
        source = config.sops.secrets."rclone_conf".path;
        mode = "0444";
    };

    systemd.services."rclone@" = {
        description = "rclone mount for remote %i";
        serviceConfig = {
            Type = "notify";
            RuntimeDirectory = "rclone";
        };
        serviceConfig.ExecStart = /* bash */ ''
            ${lib.getExe pkgs.rclone} mount \
                --config "/etc/rclone.conf" \
                --log-level "INFO" \
                --log-systemd \
                --human-readable \
                --use-mmap \
                --cache-dir "/%T/rclone_cache_%i" \
                --vfs-cache-mode "full" \
                --vfs-cache-max-size "2G" \
                --vfs-cache-max-age "10m" \
                --dir-cache-time "2m" \
                --poll-interval "1m" \
                --multi-thread-cutoff "128M" \
                --multi-thread-streams "4" \
                --umask "022" \
                --allow-other \
                --disable-http2 \
                %i: /mnt/Rclone/%i
        '';
        serviceConfig.ExecStop = "fusermount -u /mnt/Rclone/%i";
        environment = config.networking.proxy.envVars;
    };

    systemd.targets."rclone-mounts" = {
        wantedBy = [ "multi-user.target" ];
        wants = [
            "network.target"
            "rclone@Box.service"
        ];
    };

}
