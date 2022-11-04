lib:

{

  # mkSystems :: attrset -> attrset -> attrset(NixOS)
  #
  # Wraps nixpkgs' nixosSystem. Read ./README.md for documents.
  #
  mkSystems =
    { system ? "x86_64-linux"
    , localSystem ? system
    , crossSystem ? null
    , modules ? [ ]
    , nixpkgs ? null
    , overlays ? [ ]
    , config ? { }
    , arguments ? { }
    , toplevel ? [ ]
    ,
    }: {
      inherit localSystem crossSystem;
      inherit modules toplevel;
      inherit nixpkgs overlays config;
      inherit arguments;

      # This is where the magic happens.
      __functor =
        self: overrides: (import ./mkOneSystem.nix) lib (self // overrides);
    };

}
