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

    avifenc =
        libavif.override { libyuv = libyuv_teapot; }
        |> ( p: "${lib.getBin p}/bin/avifenc" )
    ;

in

rustTeapot.buildRustPackage {

    pname = "inori";
    version = "0-unstable-2025-02-25";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "d69c85070b9357a922a9d0082605ad91e29ca22b";
        hash = "sha256-W9Kuw27D7QYqfKlHMZU+nl0SCmcBxSsZLxGOV7lBZNk=";
    };

    cargoHash = "sha256-eAwG0h42EyOV59CvxBk+ETLbJUXK49WposVf1hhieUk=";
    useFetchCargoVendor = true;

    env.CFG_CJXL_PATH = cjxl;
    env.CFG_AVIFENC_PATH = avifenc;

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3"
    ;

    postInstall = /* bash */ ''
        # Remove benchmarking binaries
        find "$out" \
            -type f -iname "*_bench" \
            -exec rm -v "{}" +
        ln -sv "$out/bin/coruma-reverse" "$out/bin/,?"
    '';

    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3Plus;
    };

}

