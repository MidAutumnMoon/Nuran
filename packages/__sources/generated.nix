# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  TeapotInOri = {
    pname = "TeapotInOri";
    version = "c3fccf83af67ce60fa641304c0bba0f2bb0897da";
    src = fetchgit {
      url = "https://github.com/MidAutumnMoon/TeapotInOri";
      rev = "c3fccf83af67ce60fa641304c0bba0f2bb0897da";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-auHmjxVkurvlVMZlGJf57+DaS4OBjmu9+f664LPihrQ=";
    };
    "Cargo.lock" = builtins.readFile ./TeapotInOri-c3fccf83af67ce60fa641304c0bba0f2bb0897da/Cargo.lock;
    date = "2024-02-26";
  };
  dnsproxy = {
    pname = "dnsproxy";
    version = "v0.65.2";
    src = fetchFromGitHub {
      owner = "AdguardTeam";
      repo = "dnsproxy";
      rev = "v0.65.2";
      fetchSubmodules = false;
      sha256 = "sha256-+82dYFk5mN1p17++2Yg3GCLe8Ud4KbZIGgdfaTepEBw=";
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
  shadowsocks-rust = {
    pname = "shadowsocks-rust";
    version = "v1.18.1";
    src = fetchFromGitHub {
      owner = "shadowsocks";
      repo = "shadowsocks-rust";
      rev = "v1.18.1";
      fetchSubmodules = false;
      sha256 = "sha256-q7XtYOBruEmjPC4gx+hBO5oRwbxL7wQJenBS8Pl6yRk=";
    };
    "Cargo.lock" = builtins.readFile ./shadowsocks-rust-v1.18.1/Cargo.lock;
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
