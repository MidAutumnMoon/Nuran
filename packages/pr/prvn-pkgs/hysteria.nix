{
    runCommand,

    hysteria_teapot,
    upx-pack,
}:

runCommand "hysteria" {

    nativeBuildInputs = [ upx-pack ];

    passthru = { inherit hysteria_teapot; };

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${hysteria_teapot}/bin/hysteria" \
        "$out/bin/hysteria"
''
