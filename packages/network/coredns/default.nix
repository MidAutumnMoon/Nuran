{
    stdenvNoCC,
    fetchurl,
}:


let

    download =
        "https://github.com/coredns/coredns/releases/download/";

    version = "1.11.1";

    src = fetchurl {
        url = "${download}/v${version}/coredns_${version}_linux_amd64.tgz";
        hash = "sha256-+Wze4JNMXBKii7D7CAvtaI/de/3q4vZJhPAr3sLWVJg=";
    };

in

stdenvNoCC.mkDerivation {

    pname = "coredns";
    inherit version;

    buildCommand = ''
        tar xvf "${src}"
        install -Dm755 "coredns" "$out/bin/coredns"
    '';

    meta = {
        mainProgram = "coredns";
    };

}
