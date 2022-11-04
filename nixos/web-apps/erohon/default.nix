{ lib, config, pkgs, ... }:

let

  inherit (lib) types;

  cfg =
    config.nuran.services.erohon;

in

lib.condMod (cfg.enable) {

  imports = [
    ./git.nix
    ./web.nix
  ];


  options.nuran.services.erohon = {

    enable =
      lib.mkEnableOption "git";

    repoPath = lib.mkOption
      { type = types.str;
        description =
          "The location where repositories are stored.";
      };

    domain = lib.mkOption
      { type = types.str;
        readOnly = true;
        default = "ero.418.im";
      };

    maintenanceScripts = lib.mkOption
      { type = types.package;
        readOnly = true;
        description =
          "Attemp to make erohon mimic those git hosting platforms.";
        default =
          pkgs.callPackage ./scripts/build.nix {};
      };

    cgitPackage = lib.mkOption
      { type = types.package;
        readOnly = true;
        default = pkgs.cgit-pink;
        description =
          "which cgit to use";
      };

    cgitConfFile = lib.mkOption
      { type = types.package;
        readOnly = true;
        description =
          "the cgit configuration as a file";
      };

    account = lib.mkOption
      { type = types.str;
        readOnly = true;
        default = "git";
        description =
          "git account";
      };

  };

}
