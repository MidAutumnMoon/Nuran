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
    version = "0-unstable-2025-01-21";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "3f865d10b092a13ff8c981175ec3fc2cdbfe2f7a";
        hash = "sha256-ZDorQhrjxtnxOrnQAEopeqPgfLBBagMQ0qj1C1gJThc=";
    };

    cargoHash = "sha256-QqVJpHP49Mi84J/i2LMCCx/ZEXn7LBTRmpBq4ug4pS8=";


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

