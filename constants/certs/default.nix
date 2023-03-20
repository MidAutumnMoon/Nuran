{ lib, config, ... }:

let

  nginxCfg =
    config.nuran.nginx;

in

lib.condMod (nginxCfg.enable) {

  sops.secrets."418_fullchain" =
    { sopsFile = ./418.yml;
      owner = nginxCfg.account;
    };

  sops.secrets."418_key" =
    { sopsFile = ./418.yml;
      owner = nginxCfg.account;
    };

}
