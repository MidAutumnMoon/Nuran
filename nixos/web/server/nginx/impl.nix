{ lib, config, ... }:

let

  nginxCfg = config.nuran.nginx;

in

lib.condMod ( nginxCfg.enable ) {

  users.groups."${nginxCfg.account}" = {};

  users.users."${nginxCfg.account}" = {
    group = nginxCfg.account;
    isSystemUser = true;
  };


  sops.secrets."nginx_dhparam" =
    { sopsFile = ./secrets/dhparam.yml;
      owner = nginxCfg.account;
    };

  nuran.nginx.dhparamFile =
    config.sops.secrets."nginx_dhparam".path;


  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ];
  };

  boot.kernelModules = [ "tls" ];

}
