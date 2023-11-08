# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  cachyos-patches = {
    pname = "cachyos-patches";
    version = "ea7c01e99a6defd5d2e49a54fcbc34691defc4f8";
    src = fetchgit {
      url = "https://github.com/CachyOS/kernel-patches/";
      rev = "ea7c01e99a6defd5d2e49a54fcbc34691defc4f8";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-hUF9gIaIP4sZ7DIlc2kxLvCoR3Sg+LY98J+HqzizjuU=";
    };
    date = "2023-11-08";
  };
  derputils = {
    pname = "derputils";
    version = "2760288af3f84c5aeef6b5d714fbdfee0e9d8561";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "2760288af3f84c5aeef6b5d714fbdfee0e9d8561";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-VyOiLobtN3B0T6z/AJJ1wDqrpZ2q0QE1VyPUV+q/psQ=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-2760288af3f84c5aeef6b5d714fbdfee0e9d8561/Cargo.lock;
    date = "2023-10-30";
  };
  dnsproxy = {
    pname = "dnsproxy";
    version = "v0.57.2";
    src = fetchurl {
      url = "https://github.com/AdguardTeam/dnsproxy/releases/download/v0.57.2/dnsproxy-linux-amd64-v0.57.2.tar.gz";
      sha256 = "sha256-BcJVHQzF0l9Ylq/asqqVjK9q5KojhwAzhwZQnSUBqtw=";
    };
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
  hysteria = {
    pname = "hysteria";
    version = "app/v2.2.0";
    src = fetchurl {
      url = "https://github.com/apernet/hysteria/releases/download/app/v2.2.0/hysteria-linux-amd64";
      sha256 = "sha256-TZnFEbFNJ2+dvt6UQaoH9QDjg+ZE1CjjgnnHVrgqMys=";
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
    version = "v1.17.0";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.17.0";
      fetchSubmodules = false;
      sha256 = "sha256-Vl6COgVADAfeR0X3dFV4SHnFi0pRDw4GQv417j8+3MM=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.17.0/Cargo.lock;
  };
  tide = {
    pname = "tide";
    version = "v6.0.1";
    src = fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "v6.0.1";
      fetchSubmodules = false;
      sha256 = "sha256-oLD7gYFCIeIzBeAW1j62z5FnzWAp3xSfxxe7kBtTLgA=";
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
