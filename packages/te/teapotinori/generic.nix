{
    lib,
    sources,

    rustPlatform,
}:

{
    pname,
    subdir ? pname,

    buildInputs ? []
}:

let

    source = sources."TeapotInOri";

in

rustPlatform.buildRustPackage {

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

