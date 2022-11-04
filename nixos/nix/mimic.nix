{ lib, pkgs, flake, ... }:

let

  mimicNixpkgs = pkgs.writeTextDir "default.nix" ''
    { ... } @ args:

    let

      inherit (builtins)
        getFlake;

      overlays =
        (getFlake "${toString flake.nuclage}").totalOverlays;

      config =
        { allowUnfree = true; };

    in

    import ${toString flake.nixpkgs} ( { inherit overlays config; } // args )
    '';

in

{

  nix.nixPath = lib.mkForce
    [ "teapot=${toString mimicNixpkgs}"
      "nixpkgs=${toString flake.nixpkgs}"
      "nixos=${toString flake.nixpkgs}"
    ];

}
