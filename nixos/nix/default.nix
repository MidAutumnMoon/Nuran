{ lib, pkgs, flakes, ... }:

lib.mkMerge [

{ nix.package = pkgs.nixVersions.stable; }

{ nix.settings = {

    auto-optimise-store = true;

    keep-going = true;

    narinfo-cache-negative-ttl = 60;

    # Let cache.nixos.org be queried first.
    substituters = lib.mkAfter [
        "https://nuirrce.cachix.org"
        # "https://cache.garnix.io"
    ];

    trusted-public-keys = [
        "nuirrce.cachix.org-1:KQWa6ZfDkMPXeDiUpmyDhNw4CmgybPyeVklmi/1Rtqk="
        # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    auto-allocate-uids = true;

    use-cgroups = true;

    experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
        "pipe-operators"
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

    nix.channel.enable = false;
}

]
