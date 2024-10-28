{
    lib,
    fetchFromGitHub,
    buildFishPlugin
}:

buildFishPlugin rec {

    pname = "puffer-fish";
    version = "1.0.0-unstable-2024-03-04";

    src = fetchFromGitHub {
        owner = "nickeb96";
        repo = "puffer-fish";
        rev = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
        hash = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
    };

    meta = {
        homepage = "https://github.com/nickeb96/puffer-fish";
        license = lib.licenses.mit;
        description = "Text Expansions for Fish";
    };

}
