{ lib, config, ... }:

let

  shiori =
    config.nudata.services.shiori;

in

lib.condMod (config.services.shiori.enable) {

  services.shiori =
    { port = shiori.port;
      address = "[::1]";
    };

  systemd.services.shiori.serviceConfig =
    { Restart = "always";
      BindReadOnlyPaths = [ "/etc/resolv.conf" ];
    };

  nuran.nginx.vhosts = ''
    server {
      listen [::]:443 ssl http2;
      server_name ${shiori.domain};

      ${config.nuran.nginx.snippets."418_certs"}

      location / {
        proxy_pass http://${shiori.local_addr};
      }
    }
    '';

}
