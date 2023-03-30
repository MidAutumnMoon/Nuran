{ lib, pkgs, ... }:

lib.flatMod {

  imports = [
    ./mimic.nix
    ./registry.nix
  ];


  nix.package = pkgs.nixVersions.unstable;

  nix.settings = {

      trusted-users = [ "root" ];

      auto-optimise-store = true;

      narinfo-cache-negative-ttl = 360;

      substituters = lib.mkAfter [
          "https://nuirrce.cachix.org"
        ];

      trusted-public-keys =
        [ "nuirrce.cachix.org-1:KQWa6ZfDkMPXeDiUpmyDhNw4CmgybPyeVklmi/1Rtqk=" ];

      auto-allocate-uids = true;

      use-cgroups = true;

      experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
          "repl-flake"
          "auto-allocate-uids"
          "cgroups"
        ];

    };

  nix.nrBuildUsers = 0;

}
