{ config, pkgs, ... }:

let

  nickname = "teapot";

in

{

  users.users."${nickname}" =
    {
      isNormalUser = true;
      shell = pkgs.fish;

      description = "MidAutumnMoon";
      extraGroups = [ "wheel" ];
      hashedPassword =
        config.users.users."root".hashedPassword;
    };

  security.sudo.wheelNeedsPassword =
    false;

  nix.settings.trusted-users =
    [ nickname ];

  home-manager.users.${nickname} =
    import "${config.nudata.paths.homeProfiles}/${nickname}";

}

