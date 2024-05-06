{
    lib,
    sources,
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


    meta = {
        homepage = "https://github.com/MidAutumnMoon/TeapotInOri";
        license = lib.licenses.gpl3;
    };

}

