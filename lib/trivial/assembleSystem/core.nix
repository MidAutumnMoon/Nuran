lib: options:

let

  localSystem =
    { system = options.localSystem; };

  crossSystem =
    if options.crossSystem != null
    then { system = options.crossSystem; }
    else null;

  nixpkgsArguments = {
      inherit
        ( options ) config overlays;
      inherit
        localSystem crossSystem;
    };

  finalPkgs =
    import options.nixpkgs nixpkgsArguments;

in

lib.nixosSystem {

  specialArgs =
    { inherit lib; };

  system = localSystem;

  modules =
    options.modules
    ++ [
      # Machine-loca module
      options.toplevel

      # Apply module arguments
      { _module.args = options.arguments; }

      # Configure nixpkgs
      { nixpkgs = nixpkgsArguments // {
            pkgs = lib.mkIf ( options.nixpkgs != null ) finalPkgs;
          };
      }
    ];
}
