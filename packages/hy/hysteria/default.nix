{
    lib,
    fetchFromGitHub,

    buildGoModule,
}:

buildGoModule rec {

    pname = "hysteria";
    version = "2.6.0";

    src = fetchFromGitHub {
        owner = "apernet";
        repo = "hysteria";
        rev = "app/v${version}";
        hash = "sha256-EdqFushE/G0kWOkks7m2nSQ9wXq1p1HjebSgb5tAzmo=";
    };

    vendorHash = "sha256-P4BiWeGZCI/8zehAt+5OEZhQcA9usw+OSum9gEl/gSU=";
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
