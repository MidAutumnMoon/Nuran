{
    lib,
    fetchFromGitHub,

    stdenvNoCC,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "zhudou-sans";
    version = "1.000";

    src = fetchFromGitHub {
        owner = "Buernia";
        repo = drvSelf.pname;
        rev = "v${drvSelf.version}";
        hash = "sha256-GmKnxpsAWN2AQg+17vcdyo1h/GaNNW5Tk+d9KRZfQ/U=";
    };

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
