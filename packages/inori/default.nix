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
    version = "0-unstable-2025-02-21";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "67badf18ce26811408b4a3d7992a668ea2113b0e";
        hash = "sha256-nLWhKv4/Ap+t64w25NiQYR7AcAmcNswj+gACjA0o1AM=";
    };

    cargoHash = "sha256-KFOdSsrJ987XrZCxpxQ4OU/iP9qfT8F3m6Z8q2VmCns=";
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

