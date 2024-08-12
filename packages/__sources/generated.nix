# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  InOri = {
    pname = "InOri";
    version = "2de7316c5842e8e2ba89b57028ea3096b6d6789e";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/InOri";
      rev = "2de7316c5842e8e2ba89b57028ea3096b6d6789e";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-YWeVwBL2bbk7WjvLk2OffNMfWCaqI6DOtSFG26ses+o=";
    };
    "Cargo.lock" = builtins.readFile ./InOri-2de7316c5842e8e2ba89b57028ea3096b6d6789e/Cargo.lock;
    date = "2024-08-12";
  };
  doh-server = {
    pname = "doh-server";
    version = "0.9.11";
    src = fetchurl {
      url = "https://github.com/DNSCrypt/doh-server/releases/download/0.9.11/doh-proxy_0.9.11_linux-x86_64.tar.bz2";
      sha256 = "sha256-C30XbZ0OojRcmuX6PLxTfj9/cd5kqx/rJ5ggl+DS6zY=";
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
    version = "app/v2.5.0";
    src = fetchFromGitHub {
      owner = "apernet";
      repo = "hysteria";
      rev = "app/v2.5.0";
      fetchSubmodules = false;
      sha256 = "sha256-vtGJRPQBOO8Ig794FJ3gTrR0LOZdWH1vAc7IcZSq/SE=";
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
  puffer-fish = {
    pname = "puffer-fish";
    version = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
    src = fetchgit {
      url = "https://github.com/nickeb96/puffer-fish";
      rev = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
    };
    date = "2024-03-03";
  };
  rust-analyzer = {
    pname = "rust-analyzer";
    version = "2024-08-12";
    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = "2024-08-12";
      fetchSubmodules = false;
      sha256 = "sha256-xAxVDxuvCs8WWkrxVWjCiqxTkHhGj7sSppr1YMuEdT8=";
    };
    cargoLock."Cargo.lock" = {
      lockFile = ./rust-analyzer-2024-08-12/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  shadowsocks-rust = {
    pname = "shadowsocks-rust";
    version = "v1.20.3";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.20.3";
      fetchSubmodules = false;
      sha256 = "sha256-TVD6yI/I6R2sZGdyE0JsbuN9u5e23MRQCsKpi85JEGM=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.20.3/Cargo.lock;
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
