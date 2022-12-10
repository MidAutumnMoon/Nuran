{ lib, pkgs, flake, ... }:


{

  nix.nixPath = lib.mkForce [
      "nixpkgs=${toString flake.nixpkgs}"
      "nixos=${toString flake.nixpkgs}"
    ];

}
