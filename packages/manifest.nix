with builtins;
with ( getFlake (toString ../.) ).packages."${currentSystem}";

{

    kernels-modules = let
        kpackage = linuxPackages_teapot;
    in [
        kpackage.kernel.all
    ];

    parallel-1 = [
        hentai-home
        unrar
        gtkgreet_teapot
        nixd
        fastfetch
    ];

    parallel-2 = [
        neovim_teapot
        ruby_teapot
        ruby_teapot.brewed
        ruby_teapot.for_dev
    ];

    parallel-3 = [
        iosevka_teapot
    ];

    some-things = [
        shadowsocks_teapot
        hysteria_teapot
    ]
        ++ prvn-pkgs.all
    ;

    rust-things = [
        rust-analyzer_teapot
    ]
        # ++ inori.all
    ;

    go-things = [
        sops-install-secrets
        caddy_teapot
    ];

}
