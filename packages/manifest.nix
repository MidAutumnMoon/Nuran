with builtins;
with ( getFlake (toString ../.) ).packages."${currentSystem}";

{

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
        ruby_teapot.with_preferred_gems
        ruby_teapot.rubocop
    ];

    some-things = [
        shadowsocks_teapot
        hysteria_teapot
    ]
        ++ prvn-pkgs.all
    ;

    rust-things = [
        rust-analyzer_teapot
        colmena
        inori
    ];

    go-things = [
        sops-install-secrets
        caddy_teapot
    ];

}
