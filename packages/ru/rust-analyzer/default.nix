{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2024-10-28";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        rev = version;
        hash = "sha256-FsPsSjqnqMHBgDdM24DFLw4YOw0mFKYFJBcLaI6CvI8=";
    };

    cargoHash = "sha256-eT5JIrUUMWL6e7oh032sa2RlBxeomVBYYPH2v6yYpk8=";


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
