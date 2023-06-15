{
    stdenvNoCC,

    iosevka,
    nerd-font-patcher,
}:

let

    myIosevka = iosevka.override {
        set = "teapot";
        privateBuildPlan =
            builtins.readFile ./plan.toml;
    };

in

stdenvNoCC.mkDerivation {

    pname = "iosevka-teapot";
    version = myIosevka.version;

    nativeBuildInputs = [
        nerd-font-patcher
    ];

    buildCommand = ''
        declare -r FontDir="$out/share/fonts/truetype"
        declare -r FileList="$TMPDIR/filelist"
        mkdir -pv "$FontDir"

        find "${myIosevka}" -type f \
            \( -name '*.ttf' -o -name '*.otf' \) \
            -print0 \
        > "$FileList"

        xargs -r0 --max-procs="$NIX_BUILD_CORES" -I{} \
            nerd-font-patcher \
                --makegroups -1 \
                --careful \
                --outputdir  "$FontDir" {} \
        < "$FileList"
    '';

    meta = myIosevka.meta;

}
