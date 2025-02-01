{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,

    libavif,
    libyuv_teapot,
    libjxl,
}:

let

    cjxl = "${lib.getBin libjxl}/bin/cjxl";

    fixedLibavif = lib.onceride libavif
        ( _: { libyuv = libyuv_teapot; } )
        ( old : {
            cmakeFlags = old.cmakeFlags ++ [ "-DAVIF_LIBSHARPYUV=SYSTEM" ];
        } )
    ;

    avifenc = "${lib.getBin fixedLibavif}/bin/avifenc";

in

rustTeapot.buildRustPackage {

    pname = "inori";
    version = "0-unstable-2025-01-29";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "f4a9cda5341a7d669edb29891863e6155a4e31bf";
        hash = "sha256-Z7HUM9o9/mCdny59x2UpTLUJChj1CnNxQDSeiXYhuWM=";
    };

    cargoHash = "sha256-QM/RofouythMCOHU27BARFW2oT/4dZwmhO6OHzTxxjc=";


    env.CFG_CJXL_PATH = cjxl;
    env.CFG_AVIFENC_PATH = avifenc;

    doCheck = false;

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3"
    ;

    postInstall = /* bash */ ''
        # Remove benchmarking binaries
        find "$out" \
            -type f -iname "*_bench" \
            -exec rm -v "{}" +
    '';


    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3;
    };

}

