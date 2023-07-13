{
    lib,
    sources,
    teapot,

    rustPlatform,

    SDL2,
}:

rustPlatform.buildRustPackage rec {

    pname = "derputils";
    version = "unstable";

    inherit ( sources.${pname} ) src;
    inherit ( teapot ) RUSTFLAGS;

    cargoLock.lockFileContents =
        sources.${pname}."Cargo.lock";


    buildInputs = [
        SDL2
    ];


    meta = {
        homepage = "https://github.com/MidAutumnMoon/derputils";
        license = lib.licenses.mit;
    };

}

