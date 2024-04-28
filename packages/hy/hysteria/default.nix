{
    lib,
    sources,
    vendorhash,

    buildGoModule,
}:

buildGoModule rec {

    pname = "hysteria";

    version = builtins.head (
        builtins.match
            "app/v(.*)"
            sources.${pname}.version
    ) ;

    src = sources.${pname}.src;

    vendorHash = vendorhash.${pname};
    proxyVendor = true;

    ldflags =
        let cmd = "github.com/apernet/hysteria/app/cmd";
    in [
        "-s" "-w"
        "-X ${cmd}.appVersion=${version}"
        "-X ${cmd}.appType=release"
    ];

    # postInstall = ''
    #     mv $out/bin/app $out/bin/hysteria
    # '';

    doCheck = false;

    meta = with lib; {
        homepage = "https://github.com/apernet/hysteria";
        license = licenses.mit;
        platforms = platforms.unix;
        mainProgram = pname;
    };

}