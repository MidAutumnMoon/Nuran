{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";
    version = "2025-01-08";

    src = fetchFromGitHub {
        owner = "rust-lang";
        repo = pname;
        tag = version;
        hash = "sha256-dzslslI/5YEppCztz4FZ1VwXnb4SbuXWbSvDuWs0KKI=";
    };

    cargoHash = "sha256-AXYOa7YuiAQX7Cd+0biAaBbhy7xyjGTenDacU2pcK+M=";


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
