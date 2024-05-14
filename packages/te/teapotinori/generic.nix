{
    lib,
    sources,
    stdenv,

    rustTeapot,
    pkgsStatic,

}:

{
    pname,
    subdir ? pname,
    static ? false,
    check ? true,

    buildInputs ? []
}:

let

    source = sources."TeapotInOri";

in

pkgsStatic.rustTeapot.buildRustPackage {

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

    useNextest = true;

    doCheck = check;


    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3";


    meta = {
        homepage = "https://github.com/MidAutumnMoon/TeapotInOri";
        license = lib.licenses.gpl3;
    };

}

