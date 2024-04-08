{
    lib,
    stdenv,
    doh-proxy-rust,

    runCommand,
    pkgsStatic,

    upx-pack,
}:

let mine = lib.onceride doh-proxy-rust

( _: {

    rustPlatform = pkgsStatic.rustPlatform;

} )

( _: {

    doCheck = false;

    stripAllList = [ "bin" ];

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v2";

    buildNoDefaultFeatures = true;
    buildFeatures = [];

} );

in

runCommand "doh-server" {

    nativeBuildInputs = [ upx-pack ];

} ''
    mkdir -pv "$out/bin"

    upx-pack \
        "${mine}/bin/doh-proxy" \
        "$out/bin/doh-server"
''
