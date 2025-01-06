{
    lib,
    fetchFromGitHub,

    buildFishPlugin
}:

buildFishPlugin rec {

    pname = "tide";
    version = "6.1.1";

    src = fetchFromGitHub {
        owner = "IlanCosman";
        repo = "tide";
        tag = "v${version}";
        hash = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
    };

    fixupPhase = ''
        cp --verbose --recursive \
        'functions/tide' "$out/share/fish/vendor_functions.d"
    '';

    meta = {
        homepage = "https://github.com/IlanCosman/tide";
        license = lib.licenses.mit;
        description = "The ultimate Fish prompt.";
    };

}
