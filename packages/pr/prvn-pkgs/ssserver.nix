{
    runCommand,

    upx-pack,
    pkgsHostHost,
}:

let

    shadowsocks = pkgsHostHost.shadowsocks_teapot;

in

runCommand "ssserver" {

    nativeBuildInputs = [ upx-pack ];

    meta = { inherit shadowsocks; };

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${shadowsocks}/bin/ssserver" \
        "$out/bin/ssserver"
''
