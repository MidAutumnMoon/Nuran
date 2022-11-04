lib:

let

  inherit (builtins)
    isFunction
    mapAttrs removeAttrs
    ;

  inherit (lib.nuran.flake)
    forEachSystem
    ;


  # _callpkgs :: nixpkgs -> attrset -> attrset
  #
  _callpkgs =
    nixpkgs: options:
      forEachSystem (
        system: import nixpkgs ( options // { inherit system; } )
      );


  # _apply :: (attrset -> whatever) -> instance of pkgs -> whatever
  #
  _apply =
    func: pkgs:
      let
        result = func pkgs;
      in
        if lib.isDerivation result
        then { default = result; }
        else result;


  # __functor :: attrset -> (attrset -> whatever) -> attrset
  #
  __functor =
    self: func:
      assert isFunction func;
      mapAttrs (_: pkgs: _apply func pkgs) (removeAttrs self ["__functor"]);

in

{

  # importNixpkgs :: attrset -> attrset
  #
  # Import nixpkgs for common supported systems.
  #
  # The result is an attrset of system names with
  # their corresponding "baked" nixpkgs.
  #
  # There's also a __functor which can be used
  # to map a $func who accepts one instance of nixpkgs
  # over the attrset itself.
  #
  # Additionally, since nix 2.7 deprecated 'default*' outputs
  # in favor of '*.<system>.default', when that $func
  # returns a single derivation, the result will be
  # wrapped as '{ default = result; }', such way
  # the flake should probably be a tiny bit cleaner to read :)
  #
  #
  # For examples:
  #
  #   pkgsForSystems = importNixpkgs { ... };
  #
  #   whutever =
  #     pkgsForSystems."x86_64-linux".hello;
  #
  #   devShells = pkgsForSystems (
  #     pkgs: pkgs.mkShell { ... }
  #   );
  #   # and this will became
  #   # devShells.$system.default = $shell.
  #
  importNixpkgs =
    {
      nixpkgs
    , config ? { }
    , overlays ? [ ]
    ,
    }:
      (_callpkgs nixpkgs { inherit config overlays; }) // { inherit __functor; };

}
