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

  nix-index-db =
    { url = "github:Mic92/nix-index-database";
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

  pkgsBrew =
    lib.brewNixpkgs nixpkgs { inherit config overlays; };

  machine =
    lib.assembleSystem {
      inherit
        nixpkgs config overlays modules;
      arguments =
        { inherit flakes; };
    };

in {

  inherit lib;


  #
  # NixOS & deploy
  #

  nixosConfigurations."lyfua" =
    machine { toplevel = ./machines/laptop; };


  #
  # devShells
  #

  shellRecipes."nuran" = p:
    with p; [
      colmena
      sops
      ssh-to-age
    ];

  shellRecipes."cider-bubble" = p:
    with p; [
      wrangler
      mdbook
      mdbook-catppuccin
      mdbook-toc
      minify
    ];

  devShells =
    lib.brewShells pkgsBrew self.shellRecipes;

};

}

