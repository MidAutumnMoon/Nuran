{ config, ... }:

{ nuran.nginx.vhosts = ''

  server {

    listen [::]:443 ssl http2;
    server_name p.418.im;

    include ${config.nuran.nginx.snippets."default_certs"};

    location / {
      expires    max;
      add_header Cache-Control "public, immutable";
      add_header Access-Control-Allow-Origin *;

      gzip off;

      # This ending "/" is important.
      alias /srv/flaimgo/;
    }

  }

''; }
