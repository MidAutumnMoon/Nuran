{
    lib,
    stdenv,
    pkgsStatic,

    fetchFromGitHub,
}:

pkgsStatic.rustTeapot.buildRustPackage rec {

    pname = "shadowsocks-rust";
    version = "1.21.2";

    src = fetchFromGitHub {
        owner = "shadowsocks";
        repo = "shadowsocks-rust";
        rev = "v${version}";
        hash = "sha256-bvYp25EPKtkuZzplVYK4Cwd0mm4UuyN1LMiDAkgMIAc=";
    };

    cargoHash = "sha256-zmyce0Dt9ai4pNQi+b37KrCDqdjT9tQ8k2yHLDWDTXY=";


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

