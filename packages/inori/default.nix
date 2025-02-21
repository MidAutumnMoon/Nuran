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
    version = "0-unstable-2025-02-05";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "2b89e98e7ec532e5302c17bc692a2ccf2f35f9b8";
        hash = "sha256-OnydLMPp8X6cnwGvfJUnbOa7LNnuadaADUay2JTjJIg=";
    };

    cargoHash = "sha256-KzAKto5wQ39W9Re1jnKR7sW3qfzaIQpCj3fOX+v4gnI=";
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
        license = lib.licenses.gpl3;
    };

}

