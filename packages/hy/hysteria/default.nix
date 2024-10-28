{
    lib,
    fetchFromGitHub,

    buildGoModule,
}:

buildGoModule rec {

    pname = "hysteria";
    version = "2.5.2";

    src = fetchFromGitHub {
        owner = "apernet";
        repo = "hysteria";
        rev = "app/v${version}";
        hash = "sha256-ClWbA3cjQXK8tzXfmApBQ+TBnbRc6f36G1iIFcNQi7o=";
    };

    vendorHash = "sha256-I5SCr45IT8gl8eD9BburxHBodOpP+R5rk9Khczx5z8M=";
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
