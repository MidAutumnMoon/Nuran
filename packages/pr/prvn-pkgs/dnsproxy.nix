{
    sources,
    vendorhash,

    buildGoModule,
}:

# stdenv.mkDerivation ( drvSelf: {
#     name = "dnsproxy";
#     inherit ( sources.${drvSelf.name} )
#         src
#     ;
#     nativeBuildInputs = [ upx-pack ];
#     installPhase = ''
#         mkdir -p "$out/bin"
#         upx-pack "dnsproxy" "$out/bin/dnsproxy"
#     '';
# } )

let self = buildGoModule rec {

    pname = "dnsproxy";

    inherit ( sources.${pname} )
        src version
    ;

    proxyVendor = true;
    vendorHash = vendorhash."prvn-pkgs.dnsproxy";

}; in self
