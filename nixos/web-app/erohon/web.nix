{ lib, config, pkgs, ... }:

let

  cfg =
    config.nuran.services.erohon;

  nginxCfg =
    config.nuran.nginx;

in

lib.condMod (cfg.enable) {

  nuran.services.erohon.cgitConfFile = pkgs.writeText "cgit" ''
    virtual-root=/

    root-title=erohon
    root-desc=じーー
    logo=
    css=/erohon.css

    enable-index-owner=0

    enable-log-filecount=1
    enable-log-linecount=1
    enable-commit-graph=1
    enable-blame=1
    enable-follow-links=1

    max-message-length=60
    max-repodesc-length=60

    readme=:readme
    readme=:README
    readme=:README.md

    footer=${pkgs.copyPathToStore ./footer.html}

    enable-git-config=1

    # this needs to be ahead of scan-path
    section-from-path=1
    snapshots=tar.gz
    clone-prefix=https://${cfg.domain}
    scan-path=${cfg.repoPath}
    '';

  nuran.nginx.vhosts = ''
    server {
      listen [::]:443 ssl http2;
      server_name ${cfg.domain}
      root /var/empty;

      ${nginxCfg.snippets."418_certs"}

      location /erohon.css {
        expires    1y;
        add_header Cache-Control "public";
        alias ${pkgs.copyPathToStore ./erohon.css};
      }

      location /favicon.ico {
        return 404;
      }

      location ~* /(cgit.(css|png)|robots.txt) {
        expires    max;
        add_header Cache-Control "public";
        root ${cfg.cgitPackage}/cgit;
      }

      location ~ /.+/(info/refs|git-upload-pack) {
        ${nginxCfg.snippets.fastcgi}
        fastcgi_param GIT_PROJECT_ROOT ${cfg.repoPath};
        fastcgi_param GIT_HTTP_EXPORT_ALL 1;
        fastcgi_param PATH_INFO $uri;
        fastcgi_param SCRIPT_FILENAME ${pkgs.git}/libexec/git-core/git-http-backend;
        fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
      }

      location / {
        ${nginxCfg.snippets.fastcgi}
        fastcgi_param SCRIPT_FILENAME ${cfg.cgitPackage}/cgit/cgit.cgi;
        fastcgi_param CGIT_CONFIG ${cfg.cgitConfFile};
        fastcgi_param QUERY_STRING $args;
        fastcgi_param HTTP_HOST $server_name;
        fastcgi_param PATH_INFO $uri;
        fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
      }
    }
    '';

  systemd.services."nginx".serviceConfig =
    { SupplementaryGroups = [ cfg.account ]; };

  services.fcgiwrap =
    { enable = true;
      user = cfg.account;
      group = cfg.account;
      preforkProcesses = 4;
    };

  systemd.services.fcgiwrap.serviceConfig =
    { RuntimeDirectory = "fcgiwrap";
      CacheDirectory = "fcgiwrap";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies =
        [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RemoveIPC = true;
      PrivateMounts = true;
      SystemCallFilter =
        [ "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid" ];
    };

}
