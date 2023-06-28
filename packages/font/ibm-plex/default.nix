{
    lib,
    sources,
    stdenvNoCC,

    unzip,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "ibm-plex";

    inherit ( sources.${drvSelf.pname} )
        src version;

    nativeBuildInputs = [ unzip ];


    installPhase = let
        variants = [
            "IBM-Plex-Mono"
            "IBM-Plex-Sans"
            "IBM-Plex-Sans-KR"
            "IBM-Plex-Sans-JP/hinted"
            "IBM-Plex-Serif"
        ];
    in ''
        declare -r FontDir="$out/share/fonts/opentype"
        mkdir -p "$FontDir"
        unzip "$src"

        ${ toString ( map
            ( variant: "cp -v ${variant}/*.otf $FontDir ;" )
            variants
        ) }
    '';


    meta = with lib; {
        description = "IBM Plex Typeface";
        homepage = "https://www.ibm.com/plex/";
        license = licenses.ofl;
        platforms = platforms.all;
    };

} )
