{
    runCommand,

    upx-pack,
    sources,
}:

runCommand "doh-server" {

    nativeBuildInputs = [ upx-pack ];

} ''
    mkdir -pv "$out/bin"

    tar xvf "${sources.doh-server.src}"

    upx-pack \
        "doh-proxy/doh-proxy" \
        "$out/bin/doh-server"
''
