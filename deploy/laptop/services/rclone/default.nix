{ config, ... }:

let

  builder = import ./builder.nix;

  config_path =
    config.sops.secrets."rclone_config".path;

in

{

  imports = [

    ( builder rec {
        remoteName = "GeneralBox";
        mountPoint = "%h/Remote/${remoteName}";
        configPath = config_path;
      } )

    ( builder rec {
        remoteName = "CommonBox";
        mountPoint = "%h/Remote/${remoteName}";
        configPath = config_path;
      } )

  ];

  sops.secrets."rclone_config" = {
      owner = config.users.users.teapot.name;
      sopsFile = ./config.yml;
    };

}
