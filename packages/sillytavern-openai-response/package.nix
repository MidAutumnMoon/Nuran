{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {

    pname = "sillytavern-openai-response";
    version = "unstable";

    src = fetchFromGitHub {
        owner = "AES0529";
        repo = "SillyTavern-OpenAI-Responses";
        rev = "c153fec7a8e1af22b25fb94e75eaf2e3a746c11a";
        hash = "sha256-/5RB/WdD16DOeNicsqEyRjCXNb6vkiWA5CQndDntgN4=";
    };

    installPhase = ''
        mkdir -p "$out"
        cp -r ./* "$out/"
    '';

    meta = {
        description = "OpenAI Responses API support for SillyTavern.";
        license = lib.licenses.agpl3;
        # No license file in the repo.
        maintainers = [ ];
        platforms = lib.platforms.all;
        # Pure JS data package — no nodejs runtime closure.
    };

}
