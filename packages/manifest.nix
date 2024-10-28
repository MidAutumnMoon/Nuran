with builtins;
with ( getFlake (toString ../.) ).legacyPackages."${currentSystem}";

{

    kernels-modules = let
        kpackage = linuxPackages_teapot;
    in [
        kpackage.kernel.all
        #kpackage.nvidiaPackages.stable.open
    ];

    parallel-1 = [
        hentai-home
        unrar
        gtkgreet_teapot
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
        ++ inori.all
    ;

    go-things = [
        sops-install-secrets
        caddy_teapot
    ];

}
