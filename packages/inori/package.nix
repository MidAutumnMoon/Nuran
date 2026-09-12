{
    lib,
    stdenv,
    fetchFromGitHub,
    installShellFiles,

    tsuki,
    libjxl,
    imagemagick,
    libavif,
}:

tsuki.rust.buildRustPackage {

    pname = "inori";
    version = "0-unstable-2026-09-11";

    src = fetchFromGitHub {
        owner = "MidAutumnMoon";
        repo = "InOri";
        rev = "fd0c2c49162045293c34dac710d1673d14d6c753";
        hash = "sha256-Dm12g1Vi0FYWZEP4ME6wj3ifiTBHYmicxGNyDUr96OU=";
    };

    cargoHash = "sha256-MUI39aC/taV5ri3nW2N5CTTtkcHq76/w2AHct/7nosA=";

    doCheck = false;

    nativeBuildInputs = [
        installShellFiles
    ];

    env.CFG_CJXL_PATH = lib.getExe' libjxl "cjxl";
    env.CFG_AVIFENC_PATH = lib.getExe' libavif "avifenc";
    env.CFG_MAGICK_PATH = lib.getExe' imagemagick "magick";

    RUSTFLAGS = with stdenv;
        lib.optional hostPlatform.isx86_64 "-Ctarget-cpu=x86-64-v3"
    ;

    postFixup = /*sh*/ ''
    '';

    postInstall =
        let
            canExe = with stdenv;
                buildPlatform.canExecute hostPlatform;
        in ''
            ln -sv "$out/bin/derputils" "$out/bin/,?"

            rm -v "$out/bin/xsleep"
            rm -v "$out/bin/xecho"
        '' + (lib.optionalString canExe ''
            bin="$out/bin/i"
            installShellCompletion --cmd i \
                --bash <("$bin" completion bash) \
                --fish <("$bin" completion fish) \
                --zsh <("$bin" completion zsh)
        '');

    meta = {
        homepage = "https://github.com/MidAutumnMoon/InOri";
        license = lib.licenses.gpl3Plus;
    };

}
