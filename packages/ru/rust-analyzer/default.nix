{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2024-11-18";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        rev = version;
        hash = "sha256-isYgZVCLHYoXPtkns2jL+QAKFxnZ6lXCvKO7mT4ooiE=";
    };

    cargoHash = "sha256-oYihChXJvAI+qXjEBrwnc8CHd8hjpwGDkl/qsBoIGP8=";


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
