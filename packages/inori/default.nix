{
    lib,
    stdenv,
    fetchFromGitHub,

    rustTeapot,
}:

rustTeapot.buildRustPackage {

    pname = "inori";
    version = "unstable";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "b488b1aa3355a89317a92ac4f07b666add414b95";
        hash = "sha256-Nn1PjJIf0JRh8VZKm0HTKIlieToAYnP1IB4+mNFhXt4=";
    };

    cargoHash = "sha256-55EdZMvOW4IbLj5pCDPN7ubo6L8gW6/mnFnQLrG33i4=";


    doCheck = false;

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3"
    ;

    postInstall = /* bash */ ''
        # Remove benchmarking binaries
        find "$out" \
            -type f -iname "*_bench" \
            -exec rm -v "{}" +
    '';


    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3;
    };

}

