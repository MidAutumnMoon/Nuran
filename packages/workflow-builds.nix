with builtins;
with ( getFlake (toString ../.) ).legacyPackages."${currentSystem}";

{

  kernels-modules = [
    linuxPackages_teapot.kernel.all
  ];

  parallel-1 = [
    hentai-home
    k380-fn-keys-swap
    unrar
    nginx_teapot
  ];

  parallel-2 = [
    plasma5Packages.kwallet-pam
    watchgha
    nvfetcher_git
  ];

  parallel-3 = [
    iosevka_teapot
  ];

  rust-things = [
    derputils
    mdbook-toc
    colmena_git
    nil
  ];

  rust-heavy-things = [
    shadowsocks_teapot
  ];

  go-things = [
    sops-install-secrets
  ];

  lua-things = [
    neovim_teapot
    luajit_teapot
    moonscript
  ];

}
