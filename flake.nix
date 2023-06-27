{

description = "MidAutumnMoon's system collection, aka the Nuran.";


inputs = {

    nixpkgs.url =
        "github:NixOS/nixpkgs/nixos-unstable-small";

    nixpkgs-master.url =
        "github:NixOS/nixpkgs/master";

    # Some packages

    colmena = {
        url = "github:zhaofengli/colmena";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nil-lsp = {
        url = "github:oxalica/nil";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nvfetcher = {
        url = "github:berberman/nvfetcher";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    # Some modules

    impermanence.url =
        "github:nix-community/impermanence";

    sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
        url = "github:Mic92/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs";
    };

};


outputs = { self, nixpkgs, ... } @ flakes: let

    lib = nixpkgs.lib.extend ( import ./lib );

    overlays =
        builtins.attrValues self.overlays;

    config = {
        allowUnfree = true;
    };

    pkgsBrew =
        lib.brewNixpkgs nixpkgs { inherit config overlays; };

    machine = lib.assembleSystem {
        inherit nixpkgs config overlays;
        modules = self.nixosModules;
        arguments = { inherit flakes; };
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

    legacyPackages =
        let
            pkgsBrewMaster =
                lib.brewNixpkgs flakes.nixpkgs-master { inherit config overlays; };
        in pkgsBrewMaster lib.id;


    /*
     *
     * NixOS & deploy
     *
     */

    nixosConfigurations = {
        reuuko = machine { toplevel = ./machines/laptop; };
    };

    homeModules = with flakes; [
        nix-index-db.hmModules.nix-index
    ] ++ ( lib.listAllModules ./home );

    nixosModules = with flakes; [
        ./constants
        sops-nix.nixosModules.default
        impermanence.nixosModule
        home-manager.nixosModule
    ] ++ ( lib.listAllModules ./nixos );


    colmena = lib.adoptColmena
        self.nixosConfigurations
        {
            meta = {
                nixpkgs = pkgsBrew."x86_64-linux";
            };
            reuuko.deployment = {
                allowLocalDeployment = true;
                targetHost = "localhost";
                targetPort = 47128;
            };
        };


    /*
     *
     * devShells
     *
     */

    shellRecipes = {

        default = self.shellRecipes.nuran;

        nuran = p: with p; [
            colmena_git
            sops
            ssh-to-age
        ];

        nuclage = p: with p; [
            nvfetcher_git
        ];

        numinus = p: with p; [
            moonscript
            watchexec
            rsync
        ];

        cider-bubble = p: with p; [
            wrangler
            mdbook
            mdbook-toc
            minify
        ];

        rust = p: with p; [
            rustc
            cargo
            cargo-bloat
            cargo-nextest
            cargo-outdated
            cargo-edit
            clippy
            rustfmt
            rust-analyzer
            stdenvTeapot.cc
            pkg-config
        ];

        rust-gtk4 = p: with p; [
            cairo
            gtk4
            gdk-pixbuf
            pango
            libadwaita
        ] ++ ( self.shellRecipes.rust p );

        picno = p: with p; [
            xxHash
            waifu2x-converter-cpp
        ];

        music = p: with p; [
            picard
            shntool
            cuetools
            flac
        ];

        kernel = p: with p; [
            gcc
            ncurses
            flex
            bison
        ];

    };

    devShells =
        lib.brewShells pkgsBrew self.shellRecipes;

};

}

