{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2024-11-11";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        rev = version;
        hash = "sha256-TDI1s2Sc/rpMLwful1NcTjYBbqzbQ4Mjw5PPOuOXVfg=";
    };

    cargoHash = "sha256-ueesmr+MPByyx9ze4S3cByANVqT3Fs7LsY9A9P7bS9A=";


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
