{
    lib,
    symlinkJoin,
    makeWrapper,

    neovim-unwrapped,
    vimPlugins,

    # Enable all parsers adds about 200MB to the closure.
    treesitter ? true,
}:

let

    ts-parsers = symlinkJoin {
        name = "ts-parsers";
        paths = vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
        postBuild = /* bash */ ''
            declare -r path="$out/nvim/site"
            mkdir -vp "$path"
            mv -v -t "$path" "$out/parser"
        '';
    };

    xdgDataDirs = [
        "/run/current-system/sw/share"
        ( lib.optional treesitter ( toString ts-parsers ) )
    ]
    |> lib.flatten
    |> lib.concatStringsSep ":"
    ;

    xdgConfigDirs = lib.concatStringsSep ":" [
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
            --set XDG_DATA_DIRS "${xdgDataDirs}" \
            --set XDG_CONFIG_DIRS "${xdgConfigDirs}"

        ln -s "$out/bin/nvim" "$out/bin/vi"
        ln -s "$out/bin/nvim" "$out/bin/vim"
    '';


    passthru = {
        inherit
            ts-parsers
            neovim-unwrapped
        ;
    };

    meta.mainProgram = "nvim";

}
