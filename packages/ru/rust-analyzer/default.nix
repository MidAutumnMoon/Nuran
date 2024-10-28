{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2024-10-21";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        rev = version;
        hash = "sha256-1W5B/CnLgdC03iIFG0wtawO1+dGDWDpc84PeOHo2ecU=";
    };

    cargoHash = "sha256-k6Mbo90Bt1Cs5LOCWLEcds5629/TgMAZu2W+gmT6+ns=";


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
