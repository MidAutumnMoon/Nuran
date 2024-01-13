{
    stdenv,
    upx-pack,
    which,

    shadowsocks_teapot,
}:

stdenv.mkDerivation ( drvSelf: {

    name = "ssserver";

    nativeBuildInputs = [
        upx-pack
        which
    ];

    strictDeps = true;

    buildCommand = ''
        mkdir -p "$out/bin"
        upx-pack "${shadowsocks_teapot}/bin/ssserver" \
            "$out/bin/ssserver"
    '';

} )
