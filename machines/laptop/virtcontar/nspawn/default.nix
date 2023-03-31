{ lib, ... }:

lib.mkMerge [

{ systemd.nspawn."arch" = {

  enable = true;

  execConfig = {
      Boot = true;
      PrivateUsers = 0;
    };

  networkConfig.Private = false;

}; }

{

  security.polkit.extraConfig =
    builtins.readFile ./policy.js;

}

]
