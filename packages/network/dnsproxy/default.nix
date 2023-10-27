{
    lib,
    sources,
    stdenvNoCC,

    unzip,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "dnsproxy";

    inherit ( sources.${drvSelf.pname} )
        src version;

    installPhase = ''
        install -Dm755 dnsproxy "$out/bin/dnsproxy"
    '';


    meta = with lib; {
        homepage = "https://github.com/AdguardTeam/dnsproxy";
        license = licenses.asl20;
    };

} )
