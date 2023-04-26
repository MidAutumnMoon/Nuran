{ pkgs, config, ... }:

let

  snippet =
    name: text:
      { nuran.nginx.snippets.${name} = pkgs.writeText name text; };

  secrets =
    config.sops.secrets;

in

{ imports = [

  ( snippet "default_certs" ''
    ssl_certificate ${secrets."418_fullchain".path};
    ssl_certificate_key ${secrets."418_key".path};
  '' )

]; }
