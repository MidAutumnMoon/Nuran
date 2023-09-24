{
    pkgs,
    system,

    lib,
    sources,
    teapot,

    rustPlatform
}:

let

    config = let
        musl = lib.systems.examples.musl64;
    in {
        inherit system;
        crossSystem = musl // { rustc = musl; };
    };


    muslPower = import pkgs.path config;

in

muslPower.rustPlatform.buildRustPackage rec {

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
        "dns-over-tls"
        "dns-over-https"
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

