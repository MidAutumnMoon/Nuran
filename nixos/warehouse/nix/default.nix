{ lib, pkgs, flakes, ... }:

lib.mkMerge [

{
  nix.package = pkgs.nixVersions.stable;
}


{ nix.settings = {

  trusted-users = [ "root" ];

  auto-optimise-store = true;

  narinfo-cache-negative-ttl = 360;

  # Query cache.nixos.org first
  substituters = lib.mkAfter [
    "https://nuirrce.cachix.org"
  ];

  trusted-public-keys = [
    "nuirrce.cachix.org-1:KQWa6ZfDkMPXeDiUpmyDhNw4CmgybPyeVklmi/1Rtqk="
  ];

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

}; }


{ nix.registry = {

  "short" = {
    from = { id = "p"; type = "indirect"; };
    to = { type = "path"; path = flakes.nixpkgs; };
  };

}; }


{
  nix.nixPath = lib.mkForce [
    "nixpkgs=${toString flakes.nixpkgs}"
    "nixos=${toString flakes.nixpkgs}"
  ];
}

]
