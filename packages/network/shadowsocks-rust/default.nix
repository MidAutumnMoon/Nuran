{
    lib,
    sources,
    teapot,

    rustPlatform
}:

rustPlatform.buildRustPackage rec {

    pname = "shadowsocks-rust";

    inherit ( sources.${ pname } )
        src version;

    inherit ( teapot ) RUSTFLAGS;

    doCheck = false;


    cargoLock = {
        lockFileContents = sources.${pname}."Cargo.lock";
    };

    buildNoDefaultFeatures = true;

    buildFeatures = [
        "service"
        "trust-dns"
        "local-http"
        "local-tunnel"
        "dns-over-tls"
        "dns-over-https"
        "mimalloc"
        "multi-threaded"
        "aead-cipher-2022"
        "logging"
        "security-replay-attack-detect"
    ];


    meta = {
        homepage = "https://github.com/shadowsocks/shadowsocks-rust";
        license = lib.licenses.mit;
    };

}

