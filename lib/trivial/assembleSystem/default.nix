lib:

{

  # assembleSystem :: attrset -> attrset -> attrset(NixOS)
  #
  # Wraps nixpkgs' lib.nixosSystem.
  #
  assembleSystem =
    {
      system ? "x86_64-linux",
      localSystem ? system,
      crossSystem ? null,

      nixpkgs ? null,
      config ? { },
      overlays ? [ ],
      arguments ? { },

      modules ? [ ],
      toplevel ? {}
    }: {
      inherit localSystem crossSystem;
      inherit nixpkgs config overlays arguments;
      inherit modules toplevel;

      # Magic time!
      __functor =
        self: overrides: ( import ./core.nix ) lib ( self // overrides );
    };

}
