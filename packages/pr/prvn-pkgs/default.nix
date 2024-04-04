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
        pn-dnsproxy
        pn-ssserver
        pn-hysteria
        pn-dnscrypt
    ];

    pn-dnsproxy =
        callPackage ./dnsproxy.nix {};

    pn-ssserver =
        callPackage ./ssserver.nix {};

    pn-hysteria =
        callPackage ./hysteria.nix {};

    pn-dnscrypt =
        callPackage ./dnscrypt.nix {};

} )
