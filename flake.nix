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

        nixos-wsl = {
            url = "github:nix-community/NixOS-WSL";
            inputs.nixpkgs.follows = "nixpkgs";
        };

    };

    outputs = { self, nixpkgs, ... } @ flakes: let

        lib = nixpkgs.lib.extend ( import ./lib );

        pkgsBrew = lib.brewNixpkgs nixpkgs {
            config = { allowUnfree = true; };
            overlays = builtins.attrValues self.overlays;
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

        nixosConfigurations = let
            modules =
                with flakes; [
                    self.nixosModules.homeManagerAdapter
                    sops-nix.nixosModules.default
                    impermanence.nixosModule
                    home-manager.nixosModule
                ]
                ++ ( lib.listAllModules ./nixos )
            ;
            nixos = lib.brewNixOS {
                inherit pkgsBrew modules;
                arguments = { inherit flakes; };
            };
        in {

            joar = nixos "x86_64-linux" [ ./machine/joar ];

            loonie = nixos "x86_64-linux" [
                ./machine/loonie
                flakes.nixos-wsl.nixosModules.default
            ];

        };

        colmena = lib.nixos2colmena self.nixosConfigurations {
            meta.nixpkgs = pkgsBrew."x86_64-linux";
            joar.deployment.targetHost = "joar.home.lan";
        };

        nixosModules.homeManagerAdapter =
            { lib, ... }: let
                hmLibWithNulib =
                    "${flakes.home-manager}/modules/lib/stdlib-extended.nix"
                    |> ( f: import f lib )
                ;
            in { home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                    inherit flakes;
                    lib = hmLibWithNulib;
                };
                sharedModules =
                    self.homeModules.nuran
                    ++ [ flakes.sops-nix.homeManagerModules.sops ]
                    ++ [ { home.stateVersion = lib.trivial.release; } ]
                ;
            }; }
        ;

        homeModules.nuran = lib.listAllModules ./home;


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


        devShells = lib.brewShells pkgsBrew {

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
                gcc ncurses rustc
                flex bison
            ];

        };
    };

}

