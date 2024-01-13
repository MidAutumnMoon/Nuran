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

    cargoLock.lockFileContents =
        sources.${pname}."Cargo.lock";


    inherit ( teapot ) RUSTFLAGS;

    doCheck = false;


    buildInputs = [
        SDL2
    ];


    meta = {
        homepage = "https://github.com/MidAutumnMoon/derputils";
        license = lib.licenses.mit;
    };

}

