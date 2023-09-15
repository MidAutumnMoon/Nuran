{
    stdenvNoCC,
    fetchurl,
}:

let

    download =
        "https://github.com/apernet/hysteria/releases/download";

    version = "1.3.5";

    src = fetchurl {
        url = "${download}/v${version}/hysteria-linux-amd64";
        hash = "sha256-QdyLw//2/B8DFmbrKU8QtIG4C2YinXxqyog5jQ+6g50=";
    };

in

stdenvNoCC.mkDerivation rec {

    pname = "hysteria";
    inherit version;

    buildCommand = ''
        install -Dm755 "${src}" "$out/bin/hysteria"
    '';

    meta.mainProgram = "hysteria";

}
