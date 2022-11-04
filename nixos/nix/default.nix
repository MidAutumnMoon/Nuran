{ lib, pkgs, flake, ... }:

lib.flatMod {

  imports = [
    ./mimic.nix
  ];


  nix.package =
    pkgs.nixVersions.unstable;

  nix.settings =
    { trusted-users =
        [ "root" ];
      auto-optimise-store =
        true;
      narinfo-cache-negative-ttl =
        360;
      substituters =
        [ "https://nuirrce.cachix.org" ];
      trusted-public-keys =
        [ "nuirrce.cachix.org-1:KQWa6ZfDkMPXeDiUpmyDhNw4CmgybPyeVklmi/1Rtqk=" ];
    };

  nix.extraOptions =
    "experimental-features = nix-command flakes ca-derivations";

  # Disable documentation generating
  # to speedup system building a little bit.
  documentation.nixos.enable = false;

}
