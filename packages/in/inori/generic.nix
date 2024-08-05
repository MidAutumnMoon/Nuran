{
    lib,
    sources,
    stdenv,

    rustTeapot,
}:

{
    pname,
    subdir ? pname,
    static ? false,
    check ? true,

    buildInputs ? []
}:

let

    source = sources."InOri";

in

rustTeapot.buildRustPackage {

    inherit
        pname
        buildInputs
    ;

    version = "rolling";

    inherit ( source ) src;


    cargoLock.lockFileContents =
        source."Cargo.lock"
    ;


    buildAndTestSubdir = subdir;

    doCheck = check;


    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3";


    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3;
    };

}

