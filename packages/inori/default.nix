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
    version = "0-unstable-2025-01-13";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "f43c980669b5df5f669c5d9442a369d3805b4c50";
        hash = "sha256-IH23Pqa88X8ynWIr+i1UQMEpcxuUE2KV+mbzm0YBZtY=";
    };

    cargoHash = "sha256-owGaq8PK0XXQf27DoXjZQYyrcOjy86H4YGNU4Y4E7cA=";


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

