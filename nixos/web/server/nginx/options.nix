{ lib, pkgs, ... }:

let

  inherit ( lib ) types;

in

{ options.nuran.nginx = {

  enable =
    lib.mkEnableOption "enable Nuran's simplified Nginx";

  package = lib.mkOption
    { type = types.package;
      default = pkgs.nginx_teapot;
      readOnly = true;
    };

  vhosts = lib.mkOption
    { type = types.lines;
      description = "A list of Nginx's \"server { ... }\" blocks.";
    };

  snippets = lib.mkOption
    { type = types.attrsOf types.package;
      description = "Some shared build blocks.";
    };


  account = lib.mkOption
    { type = types.str;
      default = "nginx";
      readOnly = true;
    };

  dhparamFile =
    lib.mkOption { type = types.str; };

  configFile = lib.mkOption
    { type = types.package;
      readOnly = true;
    };

}; }
