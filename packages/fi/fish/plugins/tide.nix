{
    lib,
    fetchFromGitHub,

    buildFishPlugin
}:

buildFishPlugin rec {

    pname = "tide";
    version = "6.1.0";

    src = fetchFromGitHub {
        owner = "IlanCosman";
        repo = "tide";
        rev = "v${version}";
        hash = "sha256-OXjIBzMJ0GGD7fpxY9GVNqaB+UclbBAz4hfPcV67zfo=";
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
