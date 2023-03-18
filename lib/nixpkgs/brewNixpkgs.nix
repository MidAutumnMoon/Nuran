lib:

let

  inherit ( builtins )
    mapAttrs
    removeAttrs
    ;

  inherit ( lib.nuran.trivial )
    forEachSystem
    ;

  # importNixpkgs :: nixpkgs -> attrset -> attrset
  importForEachSystem =
    nixpkgs: options:
      forEachSystem (
        system: import nixpkgs ( options // { inherit system; } )
      );

  # __functor :: attrset -> (attrset -> whatever) -> attrset
  __functor =
    self: func:
      mapAttrs
        ( _: pkgs: func pkgs ) ( removeAttrs self [ "__functor" ] );

in

{

  # importNixpkgs :: nixpkgs -> attrset -> attrset
  #
  # Import nixpkgs for common supported systems.
  #
  # The result is an attrset of system names with
  # their corresponding "brewed" nixpkgs, typically
  # called "pkgsBrew".
  #
  # A functor which accepts an initialized nixpkgs
  # as its first argument is also attached for more
  # easily working with pkgs for variant systems.
  brewNixpkgs =
    nixpkgs: nixpkgsOptions:
      ( importForEachSystem nixpkgs nixpkgsOptions ) // { inherit __functor; };

}
