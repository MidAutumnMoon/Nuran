{ config, pkgs, lib, ... }:

let

  selfName = "teapot";

in

lib.mkMerge [

{ users.users.${selfName}= {

  inherit ( config.users.users."root" )
    hashedPassword;

  isNormalUser = true;

  shell = pkgs.fish;

  description = "MidAutumnMoon";

  extraGroups = [
      "wheel"
      config.users.groups."keys".name
    ];

}; }

{
  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [ selfName ];

  home-manager.users.${selfName}= {};
}

]
