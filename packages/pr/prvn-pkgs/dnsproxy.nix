{
    sources,
    vendorhash,

    runCommand,

    upx-pack,
    buildGo122Module,
}:

let

    dnsproxy = buildGo122Module rec {
        pname = "dnsproxy";

        inherit ( sources.${pname} )
            version src
        ;

        vendorHash = vendorhash."dnsproxy";
        proxyVendor = true;

        GOAMD64 = "v2";
        CGO_ENABLED = 0;
        doCheck = false;

        ldflags = let
            iv = "github.com/AdguardTeam/dnsproxy/internal/version";
        in [
            "-s" "-w"
            "-X" "${iv}.version=${version}"
        ];

        subPackages = [ "." ];

        meta.mainProgram = pname;
    };

in

runCommand "dnsproxy" {

    nativeBuildInputs = [ upx-pack ];

    meta = { inherit dnsproxy; };

} ''
    mkdir -pv "$out/bin"

    upx-pack "${dnsproxy}/bin/dnsproxy" \
        "$out/bin/dnsproxy"
''
