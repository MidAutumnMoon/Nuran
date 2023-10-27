{
    lib,
    sources,
    stdenvNoCC,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "hysteria";

    inherit ( sources.${drvSelf.pname} )
        src version;


    dontUnpack = true;

    installPhase = ''
        install -Dm755 "$src" "$out/bin/hysteria"
    '';


    meta = with lib; {
        homepage = "https://github.com/apernet/hysteria";
        license = licenses.mit;
    };

} )
