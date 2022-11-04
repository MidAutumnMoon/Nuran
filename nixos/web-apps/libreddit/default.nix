{ lib, config, ... }:

let

  libreddit =
    config.nudata.services.libreddit;

in

lib.condMod (config.services.libreddit.enable) {

  services.libreddit =
    { port = libreddit.port;
      address = "[::1]";
    };

  systemd.services.libreddit.environment =
    { LIBREDDIT_DEFAULT_THEME = "nord";
      LIBREDDIT_DEFAULT_SHOW_NSFW = "on";
      LIBREDDIT_DEFAULT_USE_HLS = "on";
    };

  nuran.nginx.vhosts =
    let
      proxy_pass =
        "proxy_pass http://${libreddit.local_addr};";
    in ''
    server {
      listen [::]:443 ssl http2;
      server_name ${libreddit.domain};

      ${config.nuran.nginx.snippets."418_certs"}

      location ~ /(thumb|emoji|img|style|preview|hls) {
        expires 1y;
        proxy_cache Pcache;
        ${proxy_pass}
      }

      location / {
        ${proxy_pass}
      }
    }
    '';

}
