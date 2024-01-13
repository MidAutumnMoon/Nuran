{
    lib,
    sources,

    stdenvNoCC,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "zhudou-sans";

    inherit ( sources.${drvSelf.pname} )
        version src;

    buildCommand = ''
        install -Dm444 --verbose \
            --target-directory "$out/share/fonts/opentype" \
            "$src/fonts/otf"/*.otf
    '';

    meta = {
        homepage = "https://github.com/Buernia/Zhudou-Sans";
        license = lib.licenses.ofl;
    };

} )
