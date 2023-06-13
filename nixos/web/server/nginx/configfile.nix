{ pkgs, config, ... }:

let

  nginxCfg = config.nuran.nginx;

in

{ nuran.nginx.configFile = pkgs.writeText "nuran-nginx" ''

  pid /run/nginx/nginx.pid;
  worker_processes auto;
  daemon off;
  pcre_jit on;

  events {
    multi_accept on;
    use epoll;
  }

  http {

    types_hash_max_size 4096;
    types_hash_bucket_size 256;
    client_max_body_size 8m;
    http2_push_preload on;
    charset utf-8;

    error_log stderr;
    access_log syslog:server=unix:/dev/log combined;

    # MIME
    include ${pkgs.mailcap}/etc/nginx/mime.types;
    default_type application/octet-stream;

    # Gzip
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_proxied any;
    gzip_vary on;
    gzip_static on;
    gzip_types
      application/atom+xml
      application/javascript
      application/x-javascript
      application/json
      application/manifest+json
      application/xml
      application/xml+rss
      application/rss+xml
      image/svg+xml
      text/css
      text/javascript
      text/plain
      text/xml
      font/ttf
      font/eot
      font/otf;

    # Brotli
    brotli on;
    brotli_static on;
    brotli_comp_level 5;
    brotli_window 512k;
    brotli_min_length 256;
    brotli_types
      application/atom+xml
      application/javascript
      application/x-javascript
      application/json
      application/manifest+json
      application/xml
      application/xml+rss
      application/rss+xml
      image/svg+xml
      text/css
      text/javascript
      text/plain
      text/xml
      font/ttf
      font/eot
      font/otf;

    # SSL
    ssl_session_timeout 1h;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
    ssl_ecdh_curve secp521r1:secp384r1;
    ssl_dhparam ${nginxCfg.dhparamFile};
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_conf_command Options KTLS;
    resolver 127.0.54.53;

    # Performance
    sendfile on;
    sendfile_max_chunk 512k;
    tcp_nopush on;
    tcp_nodelay on;
    directio 1m;
    open_file_cache max=10000 inactive=30s;
    open_file_cache_errors on;
    open_file_cache_min_uses 2;
    read_ahead 64k;
    ssl_dyn_rec_enable on;

    # Security
    server_tokens off;
    more_clear_headers Server;
    more_clear_headers X-Powered-By;
    more_clear_headers X-Application-Version;
    more_set_headers 'X-Content-Type-Options: nosniff';
    more_set_headers 'X-XSS-Protection: 1; mode=block';
    more_set_headers
      'Strict-Transport-Security: max-age=31536000; includeSubDomains; preload';
    more_set_headers 'X-Frame-Options: DENY';
    more_set_headers 'Referrer-Policy: strict-origin-when-cross-origin';

    # Proxy
    proxy_http_version    1.1;
    proxy_connect_timeout 60s;
    proxy_send_timeout    60s;
    proxy_read_timeout    60s;
    proxy_set_header Host              $host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host  $host;
    proxy_set_header X-Forwarded-Port  $server_port;

    # Proxy Caching
    proxy_cache_path /var/cache/nginx/rproxy
      use_temp_path=off
      levels=1:2
      keys_zone=Pcache:30m
      inactive=1d
      max_size=5g;
    proxy_cache_key  $scheme$host$proxy_host$uri$is_args$args;
    proxy_cache_lock on;
    proxy_cache_valid 200 301 302 12h;
    proxy_cache_valid any 10m;
    proxy_cache_background_update on;
    proxy_cache_use_stale
      error
      timeout
      updating
      http_502
      http_503
      http_504;
    proxy_cache_revalidate on;
    # Selectively set "proxy_cache Pcache" to blocks.

    server {
      listen [::]:443 ssl ipv6only=off
        default_server deferred reuseport
        backlog=4096;
      ssl_reject_handshake on;
      access_log /dev/null;
      error_log  /dev/null;
      location / { return 444; }
    }

    ${nginxCfg.vhosts}

  }

''; }
