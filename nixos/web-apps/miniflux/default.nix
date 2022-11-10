{ lib, config, ... }:

let

  miniflux =
    config.nudata.services.miniflux;

in

lib.condMod (config.services.miniflux.enable) {

  services.miniflux.config = {
      LOG_DATE_TIME = "true";

      LISTEN_ADDR = miniflux.local_addr;
      BASE_URL = miniflux.full_domain;

      HTTP_CLIENT_MAX_BODY_SIZE = "30";
      HTTP_CLIENT_USER_AGENT =
        "Mozilla/5.0 (X11; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0";

      POLLING_FREQUENCY = "40";
      POLLING_PARSING_ERROR_LIMIT = "6";
      POLLING_SCHEDULER = "entry_frequency";

      PROXY_IMAGES = "all";

      WORKER_POOL_SIZE = "10";

      CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
      CLEANUP_ARCHIVE_READ_DAYS = "-1";
    };


  sops.secrets."miniflux_admin".sopsFile = ./creds.yml;

  services.miniflux.adminCredentialsFile =
    config.sops.secrets."miniflux_admin".path;


  nuran.nginx.vhosts = ''
    server {
      listen [::]:443 ssl http2;
      server_name ${miniflux.domain};

      ${config.nuran.nginx.snippets."418_certs"}

      proxy_cache Pcache;

      location ~ /(proxy) {
        expires max;
        add_header Cache-Control "public, immutable";
        proxy_ignore_headers
          Cache-Control
          Vary
          Expires;
        proxy_pass http://${miniflux.local_addr};
      }

      location / {
        proxy_pass http://${miniflux.local_addr};
      }
    }
    '';

}
