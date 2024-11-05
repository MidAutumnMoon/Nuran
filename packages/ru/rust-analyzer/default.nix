{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2024-12-02";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        rev = version;
        hash = "sha256-Aob7Gf46F4BMLS0FDzf8mV39fUbNHURaY+GbYNsoOY4=";
    };

    cargoHash = "sha256-vyeNon9MTheEmGMONIbik3C9b9SKzoT4Ifpl7CJgyDE=";


    doCheck = false;

    cargoBuildFlags = [
        "--bin=rust-analyzer"
    ];

    buildFeatures = [
        "mimalloc"
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
