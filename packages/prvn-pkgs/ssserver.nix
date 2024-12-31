{
    runCommand,

    upx-pack,
    shadowsocks_teapot,
}:

runCommand "ssserver" {

    nativeBuildInputs = [ upx-pack ];

    meta = { inherit shadowsocks_teapot; };

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${shadowsocks_teapot}/bin/ssserver" \
        "$out/bin/ssserver"
''
