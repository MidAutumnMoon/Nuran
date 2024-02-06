{
    lib,
    stdenvNoCC,
    makeWrapper,

    # uses patchShebang underlaying
    shebangProgram,
}:

{
    # the script file
    path,

    # additional programs to be added into wrapper
    runtimeDeps ? [],
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    name = builtins.baseNameOf path;

    depsHostHost = [ shebangProgram ];

    nativeBuildInputs = [ makeWrapper ];

    strictDeps = true;
    dontUnpack = true;
    preferLocalBuild = true;
    allowSubstitutes = false;

    __outfile = "${placeholder "out"}/bin/${drvSelf.name}";

    buildPhase = ''
        mkdir -pv "$( dirname "$__outfile" )"
        install -Dm755 "${path}" "$__outfile"
    '';

    postFixup = ''
        wrapProgram "$__outfile" \
            --prefix PATH ":" "${lib.makeBinPath runtimeDeps}"
    '';

    meta.mainProgram = drvSelf.name;

} )
