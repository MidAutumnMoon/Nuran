# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  derputils = {
    pname = "derputils";
    version = "27a879c875834b9f8153ccd6abee2d17fa216035";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/derputils";
      rev = "27a879c875834b9f8153ccd6abee2d17fa216035";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-HGcKXhLYwglSqXAc3vJTczrof1lBQaRhmTPuhp2XYcs=";
    };
    "Cargo.lock" = builtins.readFile ./derputils-27a879c875834b9f8153ccd6abee2d17fa216035/Cargo.lock;
    date = "2023-12-25";
  };
  dnsproxy = {
    pname = "dnsproxy";
    version = "v0.61.1";
    src = fetchurl {
      url = "https://github.com/AdguardTeam/dnsproxy/releases/download/v0.61.1/dnsproxy-linux-amd64-v0.61.1.tar.gz";
      sha256 = "sha256-2kgdo6oIYSfiHfbFevRu9qEZuZlQlNscn/+TV2fT4Hk=";
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
    version = "app/v2.2.3";
    src = fetchurl {
      url = "https://github.com/apernet/hysteria/releases/download/app/v2.2.3/hysteria-linux-amd64";
      sha256 = "sha256-Y2kdoxdAcIW51qKfDFxM5tR3IsD1zEKXgrRi34WOWaw=";
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
    version = "v1.17.1";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.17.1";
      fetchSubmodules = false;
      sha256 = "sha256-2Y/tdO6vk7zE0mm9p7dL/Uq1qj/yLuelIRFMt2hxO6M=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.17.1/Cargo.lock;
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
