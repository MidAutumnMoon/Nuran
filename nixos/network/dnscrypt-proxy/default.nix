{ lib, config, pkgs, ... }:

let

  dnscryptProgram =
    lib.getExe pkgs.dnscrypt-proxy2;

  configFile =
    pkgs.writeText "dnscrypt-config" ( import ./config.nix { inherit lib config; } );

in

{ systemd.services."dnscrypt-proxy" = {

  description = "dnscrypt-proxy";

  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];

}; systemd.services."dnscrypt-proxy".serviceConfig = {

  DynamicUser = true;
  SystemCallFilter = "@system-service";

  AmbientCapabilities = "CAP_NET_BIND_SERVICE";

  RuntimeDirectory = "dnscrypt-proxy";
  StateDirectory = "dnscrypt-proxy";

  ExecStart = "${dnscryptProgram} -config ${configFile}";

}; }
