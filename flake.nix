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

  colmena =
    { url = "github:zhaofengli/colmena";
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

  pkgsBrew =
    lib.brewNixpkgs nixpkgs { inherit config overlays; };

  machine =
    lib.assembleSystem {
      inherit nixpkgs config overlays;
      modules = self.nixosModules;
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

  homeModules =
    with flakes; [
      nix-index-db.hmModules.nix-index
    ] ++ ( lib.listAllModules ./home );

  nixosModules =
    with flakes; [
      ./constants
      sops-nix.nixosModules.default
      impermanence.nixosModule
      home-manager.nixosModule
    ] ++ ( lib.listAllModules ./nixos );


  /*
  *
  * devShells
  *
  */

  shellRecipes = {

    default = self.shellRecipes.nuran;

    nuran = p: with p; [
      colmena
      sops
      ssh-to-age
    ];

    nuclage = p: with p; [
      nvfetcher
    ];

    numinus = p: with p; [
      moonscript
      watchexec
      rsync
    ];

    cider-bubble = p: with p; [
      wrangler
      mdbook
      mdbook-catppuccin
      mdbook-toc
      minify
    ];

    rust = p: with p; [
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

    picno = p: with p; [
      xxHash
      waifu2x-converter-cpp
    ];

    musicy = p: with p; [
      picard
      shntool
      cuetools
      flac
    ];

  };

  devShells =
    lib.brewShells pkgsBrew self.shellRecipes;

};

}

