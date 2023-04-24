# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cachyos-patches = {
    pname = "cachyos-patches";
    version = "977c74a08501e82592bf6767c62a9c498a973951";
    src = fetchgit {
      url = "https://github.com/CachyOS/kernel-patches/";
      rev = "977c74a08501e82592bf6767c62a9c498a973951";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-K9zr0Xfdf8tOkn+REn/zA95pEt/mHB2n7mWpNJqnamc=";
    };
    date = "2023-04-13";
  };
  derputils = {
    pname = "derputils";
    version = "c717af222511da8ebafc2bd515741bc579a40c3d";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "c717af222511da8ebafc2bd515741bc579a40c3d";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-xtfxePX39EybtP2fY9Yp7gqGhmIJL3pRZIBMXbmdOY8=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-c717af222511da8ebafc2bd515741bc579a40c3d/Cargo.lock;
    date = "2023-04-23";
  };
  graphite-cursors = {
    pname = "graphite-cursors";
    version = "2021-11-26";
    src = fetchFromGitHub ({
      owner = "vinceliuice";
      repo = "Graphite-cursors";
      rev = "2021-11-26";
      fetchSubmodules = false;
      sha256 = "sha256-Kopl2NweYrq9rhw+0EUMhY/pfGo4g387927TZAhI5/A=";
    });
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
  mdbook-catppuccin = {
    pname = "mdbook-catppuccin";
    version = "98cf81a998a49c3176854f46c6e9a971f34b1c93";
    src = fetchgit {
      url = "https://github.com/catppuccin/mdBook";
      rev = "98cf81a998a49c3176854f46c6e9a971f34b1c93";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-UoKsjLjGra5XxyVD50fTkkCd5mB9fd4cH4c1MIhe7uA=";
    };
    "Cargo.lock" = builtins.readFile ./mdbook-catppuccin-98cf81a998a49c3176854f46c6e9a971f34b1c93/Cargo.lock;
    date = "2023-03-03";
  };
  mdbook-toc = {
    pname = "mdbook-toc";
    version = "c78210ea72deaea938c8947ab1bec24b14653ea2";
    src = fetchgit {
      url = "https://github.com/badboy/mdbook-toc";
      rev = "c78210ea72deaea938c8947ab1bec24b14653ea2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-WkrXNFujLjE9dpFj2vTnmPa1beCGi7ZvyCOTW0Q/TO8=";
    };
    "Cargo.lock" = builtins.readFile ./mdbook-toc-c78210ea72deaea938c8947ab1bec24b14653ea2/Cargo.lock;
    date = "2023-02-14";
  };
  moonscript = {
    pname = "moonscript";
    version = "fa104985a6edb0890495e93515bca017031bef87";
    src = fetchgit {
      url = "https://github.com/leafo/moonscript";
      rev = "fa104985a6edb0890495e93515bca017031bef87";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-on/j+1xly1Z0VTKvonax1gnkc/Ff/efaBxhvN2LMgDM=";
    };
    date = "2023-03-22";
  };
  neovim = {
    pname = "neovim";
    version = "c1331a65dd12dd1128db5fb136a77218ef7376f1";
    src = fetchgit {
      url = "https://github.com/neovim/neovim";
      rev = "c1331a65dd12dd1128db5fb136a77218ef7376f1";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ARAp/b9LKfOOVi+D2+fu3RPv0nl+2/C1aBbSyhNl+G0=";
    };
    date = "2023-04-24";
  };
  noto-fonts-cjk = {
    pname = "noto-fonts-cjk";
    version = "Sans2.004";
    src = fetchurl {
      url = "https://github.com/googlefonts/noto-cjk/releases/download/Sans2.004/03_NotoSansCJK-OTC.zip";
      sha256 = "sha256-Uo9OGyX/O62wMhs40BXZVMTA3pJseDDvUOShlI9qPu0=";
    };
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
    version = "1a5e57d2de75d72e372b597df19c699d603ab100";
    src = fetchgit {
      url = "https://github.com/shadowsocks/shadowsocks-rust";
      rev = "1a5e57d2de75d72e372b597df19c699d603ab100";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-88quutcEmVEgChjEZK7U8ox9Nfq19KqhLZ7Ugh8ECOI=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-1a5e57d2de75d72e372b597df19c699d603ab100/Cargo.lock;
    date = "2023-04-16";
  };
  tide = {
    pname = "tide";
    version = "v5.5.1";
    src = fetchFromGitHub ({
      owner = "IlanCosman";
      repo = "tide";
      rev = "v5.5.1";
      fetchSubmodules = false;
      sha256 = "sha256-vi4sYoI366FkIonXDlf/eE2Pyjq7E/kOKBrQS+LtE+M=";
    });
  };
  watchgha = {
    pname = "watchgha";
    version = "06f262f23f3e844a389e0c6a84d58b8025337300";
    src = fetchgit {
      url = "https://github.com/nedbat/watchgha";
      rev = "06f262f23f3e844a389e0c6a84d58b8025337300";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-evX2ZpLiSYl/VLDzQXuj0SWC+wadxRxApCM8qudmwWc=";
    };
    date = "2023-04-15";
  };
  yuzu-ea-appimage = {
    pname = "yuzu-ea-appimage";
    version = "EA-3527";
    src = fetchurl {
      url = "https://github.com/pineappleEA/pineapple-src/releases/download/EA-3527/Linux-Yuzu-EA-3527.AppImage";
      sha256 = "sha256-i5AeIL/SEmFQFPV6cFrqfH61vasv1UYaJDwQiHZHRbk=";
    };
  };
}
