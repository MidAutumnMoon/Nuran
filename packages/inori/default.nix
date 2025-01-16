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
    version = "0-unstable-2025-01-14";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "3d3b9dfae5a46351acb37721986955fd68fdc532";
        hash = "sha256-j+XnOQhtLDbSvY9i2FuMQ+/bh67edeDt+NiWWTVV/Rw=";
    };

    cargoHash = "sha256-neMn6+ehVXAkw5zycIdPnUcVTh62pF/NGwVMvHzIyN4=";


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

