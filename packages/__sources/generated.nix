# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  TeapotInOri = {
    pname = "TeapotInOri";
    version = "ecbc682c342139807729481fa09293bd9bd593a6";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/TeapotInOri";
      rev = "ecbc682c342139807729481fa09293bd9bd593a6";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-6JgUITwTt9EmXcb/aXLK9YSenS+j3kQH9MJHle8JSwQ=";
    };
    "Cargo.lock" = builtins.readFile ./TeapotInOri-ecbc682c342139807729481fa09293bd9bd593a6/Cargo.lock;
    date = "2024-02-05";
  };
  dnsproxy = {
    pname = "dnsproxy";
    version = "v0.64.1";
    src = fetchurl {
      url = "https://github.com/AdguardTeam/dnsproxy/releases/download/v0.64.1/dnsproxy-linux-amd64-v0.64.1.tar.gz";
      sha256 = "sha256-Hym/sSPUBp2+E3hGOb18zqy9f3RPpQhn47/3kulrdns=";
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
  ibm-plex = {
    pname = "ibm-plex";
    version = "v6.4.0";
    src = fetchurl {
      url = "https://github.com/IBM/plex/releases/download/v6.4.0/OpenType.zip";
      sha256 = "sha256-6OUCgjqcbH3anrsXEMX2xAAdtKsVBn2ew3Om05hE/B0=";
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
    version = "v1.18.0";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.18.0";
      fetchSubmodules = false;
      sha256 = "sha256-vW1Q3pqVXR3yn2wixhDZE1QsMmUfKswaGZ6JbJAZ5VM=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.18.0/Cargo.lock;
  };
  tide = {
    pname = "tide";
    version = "v6.1.1";
    src = fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "v6.1.1";
      fetchSubmodules = false;
      sha256 = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
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
