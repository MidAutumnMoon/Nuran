with builtins;
with ( getFlake (toString ../.) ).pkgsBrewMaster."${currentSystem}";

{

    kernels-modules = let
        kpackage = linuxPackages_teapot;
    in [
        kpackage.kernel.all
        kpackage.nvidiaPackages.stable.open
    ];

    parallel-1 = [
        hentai-home
        k380-fn-keys-swap
        unrar
        nginx_teapot
        gtkgreet_teapot
    ] ++ prvn-pkgs.all;

    parallel-2 = [
        plasma5Packages.kwallet-pam
        neovim_teapot
        ibm-plex_teapot
    ];

    parallel-3 = [
        iosevka_teapot
    ];

    rust-things = [
        # derputils
        colmena_git
        nil
    ];

    rust-heavy-things = [
        shadowsocks_teapot
    ];

    go-things = [
        sops-install-secrets
    ];

}
