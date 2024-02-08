{
    buildPackages,

    writeShellApplication,
}:

writeShellApplication {

    name = "upx-pack";

    text = ''
        declare -r In="$1"
        declare -r Out="$2"

        ${buildPackages.upx}/bin/upx "$In" -o "$Out" \
            --lzma
    '';

}
