{
    lib,
    runCommandLocal,
}:

toplevel:


runCommandLocal "fish-${baseNameOf toplevel}" {}
''
    find ${toplevel} \
        -type f \
        -name '*.fish' \
        -exec cat {} + \
    > "$out"
''
