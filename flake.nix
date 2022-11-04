{

  description =
    "MidAutumnMoon's system collection, aka the Nuran.";

  inputs =
    { nixpkgs.url =
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

  outputs = { self, nixpkgs, ... } @ flake:
    let

      lib =
        nixpkgs.lib.extend (import ./lib);

      overlays =
        flake.nuclage.totalOverlays;

      config =
        { allowUnfree = true; };

      modules = with flake;
        (lib.listAllModules ./nixos)
          ++
        [ ./nudata
          sops-nix.nixosModule
          impermanence.nixosModule
          home-manager.nixosModule
        ];

      withToplevel =
        toplevel: modules ++ [ toplevel ];


      pkgsForSystems =
        lib.importNixpkgs { inherit nixpkgs config overlays; };

      machine =
        lib.mkSystems {
          inherit nixpkgs config overlays modules;
          arguments =
            { inherit flake; };
        };

    in
    {
      inherit lib;

      nixosConfigurations = { 
          lyfua =
            machine { toplevel = ./machines/laptop; };
          harumi =
            machine { toplevel = ./machines/harumi; };
        };

      colmena.meta =
        { nixpkgs =
            pkgsForSystems."x86_64-linux";
          specialArgs =
            { inherit lib flake; };
        };

      colmena."harumi".imports =
        withToplevel ./machines/harumi;

      devShells =
        lib.hexaShell pkgsForSystems [ "sops" "colmena" "ssh-to-age" ];
    };
    # outputs end & terminate the bracket slope
}

