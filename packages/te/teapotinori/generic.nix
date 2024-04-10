{
    lib,
    sources,

    rustPlatform,
    pkgsStatic,
}:

{
    pname,
    subdir ? pname,
    static ? false,

    buildInputs ? []
}:

let

    source = sources."TeapotInOri";

    rustOfChoice =
        if static
        then pkgsStatic.rustPlatform
        else rustPlatform;

in

rustOfChoice.buildRustPackage {

    inherit
        pname
        buildInputs
    ;

    version = "rolling";

    inherit ( source ) src;

    cargoLock.lockFileContents =
        source."Cargo.lock";

    buildAndTestSubdir = subdir;

    meta = {
        homepage = "https://github.com/MidAutumnMoon/TeapotInOri";
        license = lib.licenses.gpl3;
    };

}

