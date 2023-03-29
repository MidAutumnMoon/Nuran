{ lib, config, pkgs, ... }:

let

  dnscryptProgram =
    lib.getExe pkgs.dnscrypt-proxy2;

in

{

sops.secrets."dnscrypt_config".sopsFile = ./config.yml;

systemd.services."dnscrypt-proxy" = {
  description = "dnscrypt-proxy";

  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];

  serviceConfig = {

      DynamicUser = true;
      SystemCallFilter = "@system-service";

      AmbientCapabilities = "CAP_NET_BIND_SERVICE";

      RuntimeDirectory = "dnscrypt-proxy";
      StateDirectory = "dnscrypt-proxy";

      LoadCredential =
        "config:${config.sops.secrets."dnscrypt_config".path}";

      ExecStart = "${dnscryptProgram} -config %d/config";

    };
};

}
