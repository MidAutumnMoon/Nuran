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
        pn-ssserver
        pn-hysteria
        pn-dnscrypt
        pn-doh-server
    ];

    pn-ssserver =
        callPackage ./ssserver.nix {};

    pn-hysteria =
        callPackage ./hysteria.nix {};

    pn-dnscrypt =
        callPackage ./dnscrypt.nix {};

    pn-doh-server =
        callPackage ./doh-server.nix {};

} )
