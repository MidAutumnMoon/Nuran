{
    upx,

    writeShellApplication,

    nputs ? [],
}:

writeShellApplication {

    name = "upx-pack";

    runtimeInputs = [ upx ];

    text = ''
        declare -r In="$1"
        declare -r Out="$2"

        upx "$In" -o "$Out" \
            --lzma
    '';

}
