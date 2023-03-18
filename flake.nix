{

description = "MidAutumnMoon's system collection, aka the Nuran.";


inputs = {

  nixpkgs.url =
    "github:NixOS/nixpkgs/nixos-unstable-small";

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

};


outputs = { self, nixpkgs, ... } @ flakes: let

  lib =
    nixpkgs.lib.extend ( import ./lib );

  overlays =
    builtins.attrValues self.overlays;

  config =
    { allowUnfree = true; };

  modules = with flakes;
    lib.flatten [
      ./nudata
      sops-nix.nixosModule
      impermanence.nixosModule
      home-manager.nixosModule
      ( lib.listAllModules ./nixos )
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

  /*
  *
  * Overlays & packages
  *
  */

  overlays.nuclage =
    import ./packages { inherit lib; };

  overlays.reexport =
    import ./packages/reexport.nix { inherit flakes; };

  legacyPackages = pkgsBrew lib.id;


  /*
  *
  * NixOS & deploy
  *
  */

  nixosConfigurations."lyfua" =
    machine { toplevel = ./machines/laptop; };


  /*
  *
  * devShells
  *
  */

  shellRecipes."nuran" = p:
    with p; [
      colmena
      sops
      ssh-to-age
    ];

  shellRecipes."nuclage" = p:
    with p; [
      nix-build-uncached
      nvfetcher
    ];

  shellRecipes."cider-bubble" = p:
    with p; [
      wrangler
      mdbook
      mdbook-catppuccin
      mdbook-toc
      minify
    ];

  shellRecipes."rust" = p:
    with p; [
      rustc
      cargo
      clippy
      cargo-bloat
      cargo-nextest
      cargo-outdated
      rustfmt
      rust-analyzer
      stdenvTeapot.cc
    ];

  devShells =
    lib.brewShells pkgsBrew self.shellRecipes;

};

}

