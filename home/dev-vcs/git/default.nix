{ config, lib, pkgs, ... }:


lib.condMod (config.programs.git.enable) {

  imports =
    [ ./delta.nix ];


  home.packages = with pkgs;
    [ git-crypt ];

  programs.git =
    { userName = "MidAutumnMoon";
      userEmail = "me@418.im";

      signing.key = "3B9D690FD7E4664A\!";
      signing.signByDefault = true;
    };

  programs.git.aliases =
    { "root" = "rev-parse --show-toplevel"; };

  programs.git.extraConfig =
    { init.defaultBranch = "master";
      core.quotePath = false;
      http.proxy = "socks5h://127.0.0.1:1081";
    };

  programs.git.lfs.enable =
    true;

  home.sessionVariables =
    { GIT_ASKPASS = "/run/current-system/sw/bin/ksshaskpass"; };

}
