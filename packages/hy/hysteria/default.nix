{
    lib,
    fetchFromGitHub,

    buildGoModule,
}:

buildGoModule rec {

    pname = "hysteria";
    version = "2.5.0";

    src = fetchFromGitHub {
        owner = "apernet";
        repo = "hysteria";
        rev = "app/v${version}";
        hash = "sha256-vtGJRPQBOO8Ig794FJ3gTrR0LOZdWH1vAc7IcZSq/SE=";
    };

    vendorHash = "sha256-1VLws98/iAW8BnxOhbshp01D6+kb4CJOvncC5floN5o=";
    proxyVendor = true;

    doCheck = false;

    GOAMD64 = "v3";
    CGO_ENABLED = 0;

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
