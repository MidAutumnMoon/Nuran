# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  TeapotInOri = {
    pname = "TeapotInOri";
    version = "6c8db79ad974b2b68013204dd533a39637199c66";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/TeapotInOri";
      rev = "6c8db79ad974b2b68013204dd533a39637199c66";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-iYMynOTt94F0/PFdR3jeePPS9i6jS1Lv5/paMxj+URs=";
    };
    "Cargo.lock" = builtins.readFile ./TeapotInOri-6c8db79ad974b2b68013204dd533a39637199c66/Cargo.lock;
    date = "2024-06-10";
  };
  doh-server = {
    pname = "doh-server";
    version = "0.9.9";
    src = fetchurl {
      url = "https://github.com/DNSCrypt/doh-server/releases/download/0.9.9/doh-proxy_0.9.9_linux-x86_64.tar.bz2";
      sha256 = "sha256-MSt/tuokBA7+wPILVpFz1JxGAyauxtnGrxSDboJXH5w=";
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
    version = "app/v2.4.5";
    src = fetchFromGitHub {
      owner = "apernet";
      repo = "hysteria";
      rev = "app/v2.4.5";
      fetchSubmodules = false;
      sha256 = "sha256-dRVTlH+g/pwwacrdof3n8OeLMsgZswpOwvtAx13bZGo=";
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
    version = "2024-06-10";
    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = "2024-06-10";
      fetchSubmodules = false;
      sha256 = "sha256-GWUF1gT9aGIpXgD3YhPxUPKcbHrlgASZtP+etfYbDRw=";
    };
    cargoLock."Cargo.lock" = {
      lockFile = ./rust-analyzer-2024-06-10/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  shadowsocks-rust = {
    pname = "shadowsocks-rust";
    version = "v1.19.2";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.19.2";
      fetchSubmodules = false;
      sha256 = "sha256-Mru6HUq0er3zIpyaFcbFfyaoYvD+YHgU+kGp9yW5ia0=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.19.2/Cargo.lock;
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
