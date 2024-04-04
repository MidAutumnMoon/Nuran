{
    buildGoModule,
    runCommand,

    dnscrypt-proxy,
    upx-pack,
}:

let

    builder = args: buildGoModule ( args // {
        GOAMD64 = "v2";
        CGO_ENABLED = 0;
    } );

    myDnscrypt =
        dnscrypt-proxy.override { buildGoModule = builder; };

in

runCommand "dnscrypt" {

    nativeBuildInputs = [ upx-pack ];

    meta = { inherit myDnscrypt; };

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${myDnscrypt}/bin/dnscrypt-proxy" \
        "$out/bin/dnscrypt-proxy"
''
