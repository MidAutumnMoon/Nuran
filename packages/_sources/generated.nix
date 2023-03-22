# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cachyos-patches = {
    pname = "cachyos-patches";
    version = "d3503c89a63d58786e4259a524e9da9166b90cfd";
    src = fetchgit {
      url = "https://github.com/CachyOS/kernel-patches/";
      rev = "d3503c89a63d58786e4259a524e9da9166b90cfd";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-IFJC4bnhxjQyJvmMGtfnfPGWvNXaxlGNPPUocwP1HiA=";
    };
    date = "2023-03-17";
  };
  derputils = {
    pname = "derputils";
    version = "f6b049f2a7bf00e8178892d39f04049bd1923389";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "f6b049f2a7bf00e8178892d39f04049bd1923389";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-li89RqCJv0MZBBdJqaQpr7i2o2xYOY0p3FF955w2OuE=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-f6b049f2a7bf00e8178892d39f04049bd1923389/Cargo.lock;
    date = "2023-03-21";
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
    version = "a0108328373d5f3f1aefb98341aa895dd75a1b2a";
    src = fetchgit {
      url = "https://github.com/leafo/moonscript";
      rev = "a0108328373d5f3f1aefb98341aa895dd75a1b2a";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-JzWe8vKTxcixeyeCampvbqQ7/p8LkF+J0Sv/FthILwo=";
    };
    date = "2022-11-04";
  };
  neovim = {
    pname = "neovim";
    version = "a7b537c7a4e5b6114cd75df5178199f4449c6480";
    src = fetchgit {
      url = "https://github.com/neovim/neovim";
      rev = "a7b537c7a4e5b6114cd75df5178199f4449c6480";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-GoAvNR/BQmI1GVBOcO6G7deL70eqv4ZlT2c4p7CfUxw=";
    };
    date = "2023-03-22";
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
    version = "91028db4a327c9b0b7fa3e64412377b645ce9266";
    src = fetchgit {
      url = "https://github.com/shadowsocks/shadowsocks-rust";
      rev = "91028db4a327c9b0b7fa3e64412377b645ce9266";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-jauRr9EN/dJ4+c6d2tuVwLx0BMMLTsQvhbVXq9kiR/Y=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-91028db4a327c9b0b7fa3e64412377b645ce9266/Cargo.lock;
    date = "2023-03-20";
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
}
