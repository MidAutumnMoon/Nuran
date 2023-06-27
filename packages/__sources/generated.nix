# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cachyos-patches = {
    pname = "cachyos-patches";
    version = "6ebd6a6de9f445ad517d562b7f9b4d81c5293194";
    src = fetchgit {
      url = "https://github.com/CachyOS/kernel-patches/";
      rev = "6ebd6a6de9f445ad517d562b7f9b4d81c5293194";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Yo2rB1HA2RFELkgvViSa23wg1d04ttd9vq58LoprDNI=";
    };
    date = "2023-07-06";
  };
  derputils = {
    pname = "derputils";
    version = "975af6f112dd6aeb6257cbf5964f59e2ef8451f4";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "975af6f112dd6aeb6257cbf5964f59e2ef8451f4";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-SO+TxpNcvwzm/hfA7P7PDK+U38wp3kjZm9ElrHHOAbg=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-975af6f112dd6aeb6257cbf5964f59e2ef8451f4/Cargo.lock;
    date = "2023-07-17";
  };
  graphite-cursors = {
    pname = "graphite-cursors";
    version = "2021-11-26";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Graphite-cursors";
      rev = "2021-11-26";
      fetchSubmodules = false;
      sha256 = "sha256-Kopl2NweYrq9rhw+0EUMhY/pfGo4g387927TZAhI5/A=";
    };
  };
  ibm-plex = {
    pname = "ibm-plex";
    version = "v6.3.0";
    src = fetchurl {
      url = "https://github.com/IBM/plex/releases/download/v6.3.0/OpenType.zip";
      sha256 = "sha256-ghayzpmcOnBzmx/fnQXdMRUp1DW2uZgrLjnApbGC+lQ=";
    };
  };
  k380-fn-keys-swap = {
    pname = "k380-fn-keys-swap";
    version = "c0363e2e825144adc7e7ef1b37e398d90bfb0b81";
    src = fetchgit {
      url = "https://github.com/jergusg/k380-function-keys-conf/";
      rev = "c0363e2e825144adc7e7ef1b37e398d90bfb0b81";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Eubm9duEdUk8FBDbiVx2W20xKcmLrRTnrE+PiQxUuRI=";
    };
    date = "2021-11-28";
  };
  mdbook-toc = {
    pname = "mdbook-toc";
    version = "53e8bcef6e516d33a32dd610a5c5d8b7b7d98606";
    src = fetchgit {
      url = "https://github.com/badboy/mdbook-toc";
      rev = "53e8bcef6e516d33a32dd610a5c5d8b7b7d98606";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Z3ZspXD7M3VVi70+dRz7NhO6msw5htmPRX6VzhA9NPY=";
    };
    "Cargo.lock" = builtins.readFile ./mdbook-toc-53e8bcef6e516d33a32dd610a5c5d8b7b7d98606/Cargo.lock;
    date = "2023-07-18";
  };
  moonscript = {
    pname = "moonscript";
    version = "fbd8ad48737651114a3d3a672b9f8f8b3a7022b7";
    src = fetchgit {
      url = "https://github.com/leafo/moonscript";
      rev = "fbd8ad48737651114a3d3a672b9f8f8b3a7022b7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-FquMjV09oguN2ruDqQqgI5DjqzEmnF4aa+O0OMulhgs=";
    };
    date = "2023-06-23";
  };
  neovim = {
    pname = "neovim";
    version = "f2ce31d3dc1c728c33c0910e1a9970f0eb2e3f11";
    src = fetchgit {
      url = "https://github.com/neovim/neovim";
      rev = "f2ce31d3dc1c728c33c0910e1a9970f0eb2e3f11";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Xlz18WVgO3w/O5cUsQoh1uq38c/Rm3GPnOuoXVsgeXY=";
    };
    date = "2023-07-23";
  };
  puffer-fish = {
    pname = "puffer-fish";
    version = "5d3cb25e0d63356c3342fb3101810799bb651b64";
    src = fetchgit {
      url = "https://github.com/nickeb96/puffer-fish";
      rev = "5d3cb25e0d63356c3342fb3101810799bb651b64";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-aPxEHSXfiJJXosIm7b3Pd+yFnyz43W3GXyUB5BFAF54=";
    };
    date = "2023-03-15";
  };
  shadowsocks-rust = {
    pname = "shadowsocks-rust";
    version = "v1.15.4";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.15.4";
      fetchSubmodules = false;
      sha256 = "sha256-Tdh6lGk93hGuR+L2cytVoKYfRHrmuNo9OtKqQaeCMx0=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.15.4/Cargo.lock;
  };
  tide = {
    pname = "tide";
    version = "v5.6.0";
    src = fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "v5.6.0";
      fetchSubmodules = false;
      sha256 = "sha256-cCI1FDpvajt1vVPUd/WvsjX/6BJm6X1yFPjqohmo1rI=";
    };
  };
  zhudou-sans = {
    pname = "zhudou-sans";
    version = "v2.000";
    src = fetchFromGitHub {
      owner = "Buernia";
      repo = "Zhudou-Sans";
      rev = "v2.000";
      fetchSubmodules = false;
      sha256 = "sha256-0OA+37atwnCqTEBoWkSusrySYbJlc9ef+6iaW97zy3U=";
    };
  };
}
