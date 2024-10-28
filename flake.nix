{
description = "MidAutumnMoon's system collection, aka the Nuran.";


inputs = {

    nixpkgs.url =
        "github:NixOS/nixpkgs/nixos-unstable-small";

    # Some packages

    # Some toolchains

    rust-overlay = {
        url = "github:oxalica/rust-overlay";
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

    /*
     * My cute lib
     */
    inherit lib;


    /*
     * Overlays & packages
     */

    overlays.nuclage =
        import ./packages { inherit lib flakes; };

    overlays.reexport =
        import ./packages/reexport.nix { inherit flakes; };

    inherit pkgsBrew;

    packages = self.pkgsBrew lib.id;


    /*
     * Machines
     */

    nixosConfigurations = {
        reuuko = machine { toplevel = ./machine/laptop; };
    };

    nixosModules = with flakes; [
        ./constants
        sops-nix.nixosModules.default
        impermanence.nixosModule
        home-manager.nixosModule
    ] ++ ( lib.listAllModules ./nixos );


    homeConfigurations = let
        inherit ( flakes.home-manager.lib )
            homeManagerConfiguration
        ;
        home = m: homeManagerConfiguration {
            inherit lib;
            modules = m ++ self.homeModules;
            pkgs = pkgsBrew."x86_64-linux";
        };
    in {
        "WslArch" = home [ ./machine/wsl/home.nix ];
    };

    homeModules = with flakes; [ ] ++ (
        lib.listAllModules ./home
    );


    # TODO: clean up this
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
     * Apps
     */

    apps = pkgsBrew ( pkgs:
        builtins.mapAttrs ( _: d: lib.makeApp d ) (
            pkgs.callPackage ./apps.nix {}
        )
    );


    /*
     * devShells
     */

    shellRecipes = {
        default = self.shellRecipes.nuran;

        nuran = p: with p; [
            colmena sops
            ssh-to-age
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

        music = p: with p; [
            picard
            shntool cuetools flac
        ];

        kernel = p: with p; [
            gcc ncurses
            flex bison
        ];
    };

    devShells =
        lib.brewShells pkgsBrew self.shellRecipes;

};

}

