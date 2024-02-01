{
    pkgsStatic,

    lib,
    sources,
}:

pkgsStatic.rustPlatform.buildRustPackage rec {

    pname = "shadowsocks-rust";

    inherit ( sources.${pname} )
        src version;

    cargoLock.lockFileContents =
        sources.${pname}."Cargo.lock";


    doCheck = false;

    stripAllList = [ "bin" ];


    RUSTFLAGS = [ "-Ctarget-cpu=x86-64-v2" ];

    CARGO_PROFILE_release_LTO = "thin";


    buildNoDefaultFeatures = true;

    buildFeatures = [
        "service"
        "hickory-dns"
        "local-http"
        "dns-over-tls"
        "dns-over-https"
        "dns-over-h3"
        "multi-threaded"
        "aead-cipher-2022"
        "logging"
        "security-replay-attack-detect"
        "jemalloc"
    ];


    meta = {
        homepage = "https://github.com/shadowsocks/shadowsocks-rust";
        license = lib.licenses.mit;
    };

}

