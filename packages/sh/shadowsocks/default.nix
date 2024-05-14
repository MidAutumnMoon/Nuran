{
    lib,
    stdenv,
    pkgsStatic,

    sources,
}:

pkgsStatic.rustTeapot.buildRustPackage rec {

    pname = "shadowsocks-rust";

    inherit ( sources.${pname} )
        src version
    ;

    cargoLock.lockFileContents =
        sources.${pname}."Cargo.lock"
    ;


    doCheck = false;

    stripAllList = [ "bin" ];


    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3";


    buildNoDefaultFeatures = true;

    buildFeatures = [
        "service"
        "hickory-dns"
        "local-http"
        "multi-threaded"
        "aead-cipher-2022"
        "logging"
        "security-replay-attack-detect"
        "mimalloc"
    ];


    meta = {
        homepage = "https://github.com/shadowsocks/shadowsocks-rust";
        license = lib.licenses.mit;
    };

}

