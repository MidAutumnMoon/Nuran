lib:

let

  inherit ( builtins )
    isAttrs
    isList
    mapAttrs
    ;

  brewer =
    pkgs: recipe:
      let drink = recipe pkgs; in
      let mkShellImpl = pkgs.mkShellNoCC; in
      if isList drink
        then mkShellImpl { packages = drink; }
      else if isAttrs drink
        then mkShellImpl drink
      else
        drink;

in

{

  # brewShells :: pkgsBrew -> attrset of recipes -> attrset
  # where
  #   pkgsBrew: somthing cooked using ./brewNixpkgs.nix
  #   recipe: pkgs -> list | attrset | anything
  brewShells =
    pkgsBrew: recipes:
      assert isAttrs recipes;
      pkgsBrew ( pkgs: mapAttrs ( _: recipe: brewer pkgs recipe ) recipes );

}
