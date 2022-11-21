{ lib, config, pkgs, ... }:

let

  cfg = config.nuran.nginx;

  inherit (lib) types;

in

lib.condMod (cfg.enable) {

  imports = [
    ./service.nix
    ./config.nix
  ];


  # options

  options.nuran.nginx = {

    enable =
      lib.mkEnableOption "enable Nuran's simplified Nginx";

    package = lib.mkOption
      { type = types.package;
        default = pkgs.nginx-teapot;
        readOnly = true;
      };

    account = lib.mkOption
      { type = types.str;
        default = "nginx";
        readOnly = true;
      };

    vhosts = lib.mkOption
      { type = types.lines;
        description =
          "A list of Nginx's \"server { ... }\" blocks.";
      };

    # TODO: to file based snippets
    snippets = lib.mkOption
      { type = types.attrsOf types.lines;
        description =
          "Some shared build blocks.";
      };

    dhparamFile =
      lib.mkOption { type = types.str; };

    configFile = lib.mkOption
      { type = types.package;
        readOnly = true;
      };

  };


  # config

  users.groups."${cfg.account}" = {};

  users.users."${cfg.account}" = {
      group = cfg.account;
      isSystemUser = true;
    };


  nuran.nginx.snippets = {
      "418_certs" = ''
        ssl_certificate ${config.sops.secrets."418_fullchain".path};
        ssl_certificate_key ${config.sops.secrets."418_key".path};
        '';
      fastcgi =
        "include ${cfg.package}/conf/fastcgi_params;";
    };

  # a dummy server to enable some socket options
  nuran.nginx.vhosts = ''
    server {
      listen [::]:443
        ssl
        default_server
        ipv6only=off
        deferred
        reuseport
        backlog=4096;

      ssl_reject_handshake on;

      access_log /dev/null;
      error_log  /dev/null;

      location / { return 444; }
    }
    '';


  sops.secrets."nginx_dhparam" =
    { sopsFile = ./dhparam.yml;
      owner = cfg.account;
    };

  nuran.nginx.dhparamFile =
    config.sops.secrets."nginx_dhparam".path;


  networking.firewall.allowedTCPPorts = [ 443 ];

  networking.firewall.allowedUDPPorts = [ 443 ];

  boot.kernelModules = [ "tls" ];

}
