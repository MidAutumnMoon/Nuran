{ lib, config, ... }:

let

    inherit ( config.sops.secrets )
        wildcard_home_lan_crt
        wildcard_home_lan_key
    ;

in {

    systemd.services."caddy" = {
        serviceConfig.LoadCredential = [
            "wildcard_home_lan_crt:${wildcard_home_lan_crt.path}"
            "wildcard_home_lan_key:${wildcard_home_lan_key.path}"
        ];
    };

    services.caddy.enable = true;

    services.caddy.virtualHosts."https://*.home.lan" = {
        listenAddresses = [ "[::]" ];
        extraConfig = lib.mkBefore ''
            tls \
                {env.CREDENTIALS_DIRECTORY}/wildcard_home_lan_crt \
                {env.CREDENTIALS_DIRECTORY}/wildcard_home_lan_key

            encode zstd gzip
        '';
    };

}
