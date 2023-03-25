with ( builtins.getFlake (toString ../.) ).legacyPackages."${ builtins.currentSystem }";

{

  kernels-modules = [
    linuxPackages_teapot.kernel.all
  ];

  parallel-1 = [
    hentai-home
    k380-fn-keys-swap
    nerdfonts_teapot
    noto-fonts-cjk_teapot
    mpv_teapot
    unrar
    nginx_teapot
  ];

  parallel-2 = [
    plasma5Packages.kdeGear.okular
    plasma5Packages.kwallet-pam
  ];

  parallel-3 = [
    iosevka_teapot
  ];

  rust-things = [
    derputils
    mdbook-catppuccin
    mdbook-toc
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