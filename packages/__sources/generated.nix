# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cachyos-patches = {
    pname = "cachyos-patches";
    version = "033c0cabb2435c0b7a1e3fd8467419a560b71f22";
    src = fetchgit {
      url = "https://github.com/CachyOS/kernel-patches/";
      rev = "033c0cabb2435c0b7a1e3fd8467419a560b71f22";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-gVaLonQi08CJLLcjYgTLEFIPVM9LQc25gddOBjG0fko=";
    };
    date = "2023-06-01";
  };
  derputils = {
    pname = "derputils";
    version = "b116e8a80d9f094078cf3ec0089b6e3a177f38ee";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "b116e8a80d9f094078cf3ec0089b6e3a177f38ee";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-4XGwZ0GQ1mvym74G37U/jK0aNwmXn7fsFMpICc+GOXg=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-b116e8a80d9f094078cf3ec0089b6e3a177f38ee/Cargo.lock;
    date = "2023-05-05";
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
    version = "9c1ad00448a6110b2d164aac0c32a98a0e0b2ccb";
    src = fetchgit {
      url = "https://github.com/badboy/mdbook-toc";
      rev = "9c1ad00448a6110b2d164aac0c32a98a0e0b2ccb";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-89pwp1qEsG6xQgMwKBSo82q80rufNnxa/o7dujar4IE=";
    };
    "Cargo.lock" = builtins.readFile ./mdbook-toc-9c1ad00448a6110b2d164aac0c32a98a0e0b2ccb/Cargo.lock;
    date = "2023-06-01";
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
    version = "16561dac39490921715a9a8a14dab884659ffc3e";
    src = fetchgit {
      url = "https://github.com/neovim/neovim";
      rev = "16561dac39490921715a9a8a14dab884659ffc3e";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-KTB5GF0teaJDKrZNQ53EIqoNxAnEig4pqm1S9IFO/1A=";
    };
    date = "2023-06-05";
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
    version = "702690fbb1046268644731e98777d938712c8f9f";
    src = fetchgit {
      url = "https://github.com/shadowsocks/shadowsocks-rust";
      rev = "702690fbb1046268644731e98777d938712c8f9f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-gQ27tubtMHGKxQlInFH9pJTj8tedS7babQ3IrgkgHpo=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-702690fbb1046268644731e98777d938712c8f9f/Cargo.lock;
    date = "2023-06-03";
  };
  tide = {
    pname = "tide";
    version = "v5.5.1";
    src = fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "v5.5.1";
      fetchSubmodules = false;
      sha256 = "sha256-vi4sYoI366FkIonXDlf/eE2Pyjq7E/kOKBrQS+LtE+M=";
    };
  };
  watchgha = {
    pname = "watchgha";
    version = "830e536f5663147ea8fb2272773ca1377fe39d6a";
    src = fetchgit {
      url = "https://github.com/nedbat/watchgha";
      rev = "830e536f5663147ea8fb2272773ca1377fe39d6a";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-n5fjkB4mFfKajMUzHPFnHv/kjmL3In4wGhAbeIdp/9A=";
    };
    date = "2023-05-19";
  };
  yuzu-ea-appimage = {
    pname = "yuzu-ea-appimage";
    version = "EA-3638";
    src = fetchurl {
      url = "https://github.com/pineappleEA/pineapple-src/releases/download/EA-3638/Linux-Yuzu-EA-3638.AppImage";
      sha256 = "sha256-Xm2ivx1VMzZTQI7lx9bkeygRJ3T39Zy4vDBUOKqDHiI=";
    };
  };
}
