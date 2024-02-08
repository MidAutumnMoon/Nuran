{
    buildGoModule,
    runCommand,
    pkgsHostHost,

    upx-pack,
}:

let

    builder = args: buildGoModule ( args // {
        GOAMD64 = "v2";
        CGO_ENABLED = 0;
    } );

    myHysteria =
        pkgsHostHost.hysteria.override { buildGoModule = builder; };

in

runCommand "hysteria" {

    nativeBuildInputs = [ upx-pack ];

    meta = { inherit myHysteria; };

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${myHysteria}/bin/hysteria" \
        "$out/bin/hysteria"
''
