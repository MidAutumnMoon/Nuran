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
        k380-fn-keys-swap
        unrar
        nginx_teapot
        gtkgreet_teapot
    ];

    parallel-2 = [
        plasma5Packages.kwallet-pam
        neovim_teapot
        ibm-plex_teapot
        ruby_teapot
        ruby_teapot.brewed
    ];

    parallel-3 = [
        iosevka_teapot
    ];

    rust-things = [
        # derputils
        colmena_git
        nil
        shadowsocks_teapot
    ] ++ prvn-pkgs.all;

    go-things = [
        sops-install-secrets
        caddy_teapot
    ];

}
