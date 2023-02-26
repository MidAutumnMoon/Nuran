{

description = "MidAutumnMoon's system collection, aka the Nuran.";


inputs = {

  nixpkgs.url =
    "github:NixOS/nixpkgs/nixos-unstable-small";

  nulib.url =
    "github:MidAutumnMoon/Nulib";

  # Some modules

  impermanence.url =
    "github:nix-community/impermanence";

  sops-nix =
    { url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  home-manager =
    { url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  # Some overlays

  nuclage =
    { url = "github:MidAutumnMoon/Nuclage";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nulib.follows = "nulib";
    };

};


outputs = { self, nixpkgs, ... } @ flakes: let

  lib =
    nixpkgs.lib.extend ( import ./lib );

  overlays =
    flakes.nuclage.totalOverlays;

  config =
    { allowUnfree = true; };

  modules = with flakes;
    ( lib.listAllModules ./nixos ) ++
    [
      ./nudata
      sops-nix.nixosModule
      impermanence.nixosModule
      home-manager.nixosModule
    ];

  pkgsForSystems =
    lib.importNixpkgs { inherit nixpkgs config overlays; };

  machine =
    lib.assembleSystem {
      inherit
        nixpkgs config overlays modules;
      arguments =
        { inherit flakes; };
    };

in {

  inherit lib;

  nixosConfigurations."lyfua" =
    machine { toplevel = ./machines/laptop; };

  colmena.meta = {
      nixpkgs =
        pkgsForSystems."x86_64-linux";
      specialArgs =
        { inherit lib flakes; };
    };

  devShells =
    lib.hexaShell pkgsForSystems [ "sops" "colmena" "ssh-to-age" ];

}; # outputs end & terminate the bracket slope

}

