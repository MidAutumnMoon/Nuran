{
    sources,
    stdenv,

    upx-pack,
}:

stdenv.mkDerivation ( drvSelf: {

    name = "dnsproxy";

    inherit ( sources.${drvSelf.name} )
        src
    ;

    nativeBuildInputs = [ upx-pack ];

    installPhase = ''
        mkdir -p "$out/bin"
        upx-pack "dnsproxy" "$out/bin/dnsproxy"
    '';

} )
