{
    lib,
    sources,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

{
    pname,
    subdir ? pname,
    static ? false,
    check ? true,

    buildInputs ? []
}:

rustTeapot.buildRustPackage rec {

    inherit
        pname
        buildInputs
    ;

    version = "master";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "3884a1579958ac64bbcf7b3abdff31eb4ca5b805";
        hash = "sha256-8oc62B8CWlOhugwtSEOR0+aP/6Pe1Bf0mcqg/dfhDMc=";
    };

    cargoHash = "";


    buildAndTestSubdir = subdir;

    doCheck = check;


    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3";


    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3;
    };

}

