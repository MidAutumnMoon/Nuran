{
    lib,
    stdenv,
    sources,

    rustTeapot,
}:

rustTeapot.buildRustPackage rec {

    pname = "rust-analyzer";

    inherit ( sources.${pname} )
        version
        src
    ;

    cargoLock = sources.${pname}.cargoLock."Cargo.lock";


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
