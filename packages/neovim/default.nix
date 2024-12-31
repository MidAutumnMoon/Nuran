{
    lib,
    symlinkJoin,
    makeWrapper,

    neovim-unwrapped,

    tools ? [],
}:

let

    inherit ( lib )
        makeBinPath
        concatStringsSep
    ;

    xdgDataDirs = concatStringsSep ":" [
        "/run/current-system/sw/share"
    ];

    xdgConfigDirs = concatStringsSep ":" [
        "/etc/xdg"
        "/run/current-system/sw/etc/xdg"
    ];

in

symlinkJoin {

    name = "neovim";

    paths = [
        neovim-unwrapped
    ];

    nativeBuildInputs = [
        makeWrapper
    ];

    postBuild = ''
        rm -v "$out/bin/nvim"

        # nvim is smart enough to figure out his real
        # path, so no need to include the runtime in wrapper
        rm -r "$out/share/nvim"

        makeWrapper \
            "${neovim-unwrapped}/bin/nvim" "$out/bin/nvim" \
            --inherit-argv0 \
            --prefix PATH ':' '${makeBinPath tools}' \
            --set XDG_DATA_DIRS '${xdgDataDirs}' \
            --set XDG_CONFIG_DIRS '${xdgConfigDirs}'

        ln -s "$out/bin/nvim" "$out/bin/vi"
        ln -s "$out/bin/nvim" "$out/bin/vim"
    '';


    passthru.unwrapped = neovim-unwrapped;

    meta.mainProgram = "nvim";

}
