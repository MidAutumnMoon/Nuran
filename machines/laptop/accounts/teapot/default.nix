{ config, pkgs, ... }:

{

  imports = [ ./secrets ];

  users.users."teapot" = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "MidAutumnMoon";
      extraGroups = [
          "wheel"
          config.users.groups."keys".name
        ];
      hashedPassword =
        config.users.users."root".hashedPassword;
    };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [ "teapot" ];

  home-manager.users."teapot" =
    import "${config.nudata.paths.homeProfiles}/teapot";

}

