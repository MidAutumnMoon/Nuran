{
    lib,
    sources,
    newScope,
}:

lib.makeScope newScope ( self: let

    callPackage =
        self.newScope { inherit sources; };

in {

    upx-pack =
        callPackage ./upx.nix {};

    all = with self; [
        dnsproxy
        ssserver
        hysteria
    ];

    dnsproxy =
        callPackage ./dnsproxy.nix {};

    ssserver =
        callPackage ./ssserver.nix {};

    hysteria =
        callPackage ./hysteria.nix {};

} )
