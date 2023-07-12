{ lib, config, pkgs, ... }:

let

    dnscryptExe =
        lib.getExe pkgs.dnscrypt-proxy2;

    configFile = pkgs.callPackage ./config.nix {
        inherit lib pkgs config;
    };

in

lib.mkIf config.role.personal

{ systemd.services."dnscrypt-proxy" = {

    description = "dnscrypt-proxy";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
        DynamicUser = true;
        SystemCallFilter = "@system-service";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        RuntimeDirectory = "dnscrypt-proxy";
        StateDirectory = "dnscrypt-proxy";

        ExecStart = "${dnscryptExe} -config ${configFile}";
    };

}; }
