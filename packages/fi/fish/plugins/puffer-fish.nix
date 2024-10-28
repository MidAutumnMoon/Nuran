{
    lib,
    fetchFromGitHub,
    buildFishPlugin
}:

buildFishPlugin rec {

    pname = "puffer-fish";
    version = "master";

    src = fetchFromGitHub {
        owner = "nickeb96";
        repo = "puffer-fish";
        rev = "a976410a57acdf7aadcf298d7efc143981e4f160";
        hash = "sha256-S1e3QnFAPqhJJrRhYSfwYiVkA43Woj7Z6CAXGMJl4C4=";
    };

    meta = {
        homepage = "https://github.com/nickeb96/puffer-fish";
        license = lib.licenses.mit;
        description = "Text Expansions for Fish";
    };

}
