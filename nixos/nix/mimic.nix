{ lib, pkgs, flakes, ... }:


{

  nix.nixPath = lib.mkForce [
      "nixpkgs=${toString flakes.nixpkgs}"
      "nixos=${toString flakes.nixpkgs}"
    ];

}
