{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2025-02-24";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        tag = version;
        hash = "sha256-eKQ7aBkNvF5AhUpyJ1cW450jxomZ4gTIaYir5qsNl7Y=";
    };

    cargoHash = "sha256-Cu9phpGE2OIRG9HwvXBvU03cTBdo7GdWvS1baqxhFxo=";
    useFetchCargoVendor = true;

    doCheck = false;

    cargoBuildFlags = [
        "--bin=rust-analyzer"
    ];

    buildFeatures = [
        "jemalloc"
    ];


    CFG_RELEASE = version;

    CARGO_PROFILE_RELEASE_LTO = "thin";

    CARGO_PROFILE_RELEASE_STRIP = "debuginfo";

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3"
    ;


    meta = with lib; {
        homepage = "https://rust-analyzer.github.io";
        license = with licenses; [ mit asl20 ];
        mainProgram = pname;
    };
}
