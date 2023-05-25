{
  lib,
  sources,
  teapot,

  rustPlatformTeapot
}:

rustPlatformTeapot.buildRustPackage rec {

  pname = "shadowsocks-rust";
  version = "unstable";

  inherit ( sources.${ pname } ) src;

  cargoLock = {
    lockFileContents = sources.${pname}."Cargo.lock";
  };


  doCheck = false;

  inherit ( teapot ) RUSTFLAGS;


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

