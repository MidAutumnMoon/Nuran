{
    lib,
    fetchFromGitHub,

    buildGoModule,
}:

buildGoModule rec {

    pname = "hysteria";
    version = "2.6.1";

    src = fetchFromGitHub {
        owner = "apernet";
        repo = "hysteria";
        tag = "app/v${version}";
        hash = "sha256-0vd1cV2E07EntiOE0wHrSe4e/SRqbFrXhyBRFGxU7xY=";
    };

    vendorHash = "sha256-YFFhsBRWL1Rn+z8awRQiy6/5IEqD1f9CjAeIqfzrwu4=";
    proxyVendor = true;

    doCheck = false;

    env.GOAMD64 = "v3";
    env.CGO_ENABLED = "0";

    ldflags =
        let cmd = "github.com/apernet/hysteria/app/cmd";
    in [
        "-s" "-w"
        "-X ${cmd}.appVersion=${version}"
        "-X ${cmd}.appType=release"
    ];

    postInstall = ''
        mv $out/bin/{app,${pname}}
    '';


    meta = with lib; {
        homepage = "https://github.com/apernet/hysteria";
        license = licenses.mit;
        platforms = platforms.unix;
        mainProgram = pname;
    };

}
