{
    sources,
    stdenvNoCC,

    upx-pack,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    name = "hysteria";

    inherit ( sources.${drvSelf.name} )
        src
    ;

    dontUnpack = true;

    nativeBuildInputs = [ upx-pack ];

    installPhase = ''
        mkdir -p "$out/bin"
        install -Dm755 "$src" "hysteria"
        upx-pack "hysteria" "$out/bin/hysteria"
    '';

} )
