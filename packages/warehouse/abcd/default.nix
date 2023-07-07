{
    lib,
    pkgs,

    flakePath,
    flake ? builtins.getFlake ( toString flakePath ),
}:

let

    serviceName = "abcd";

    callPackage =
        pkgs.newScope { inherit lib serviceName config; };

    config = callPackage ./config.nix {
        inherit flake;
        nixosName = "reuuko";
    };

    callService =
        path: ( callPackage path {} ).service;

in

pkgs.portableService {

    pname = serviceName;
    version = "dev";

    units = [
        ( callService ./coredns )
        ( callService ./shadowsocks )
        ( callService ./hysteria )
    ];

    symlinks =
        [ { object = "${pkgs.cacert}/etc/ssl"; symlink = "/etc/ssl"; } ];

    squash-compression = "zstd";

}
