{ lib, config, pkgs, ... }:

{

  services.dnscrypt-proxy2.enable = true;

  sops.secrets."dnscrypt_conf".sopsFile = ./config.yml;

  systemd.services."dnscrypt-proxy2".serviceConfig
    .LoadCredential = "conf:${config.sops.secrets."dnscrypt_conf".path}";

  systemd.services."dnscrypt-proxy2".serviceConfig.ExecStart =
    lib.mkForce
      "${lib.getExe pkgs.dnscrypt-proxy2} -config \${CREDENTIALS_DIRECTORY}/conf";
}
