lib:

let

  inherit ( builtins )
    isList
    isString
    partition
    ;

  inherit ( lib )
    splitString
    attrByPath
    hasAttrByPath
    ;


  # getPackage :: pkgs -> string -> drv
  getPackage =
    pkgs: name:
      let attrPath = splitString "." name; in
      if hasAttrByPath attrPath pkgs then
        attrByPath attrPath null pkgs
      else
        throw "Package \"${name}\" not found";

in

{

  # hexaShell :: (pkgs as of ./import.nix) -> [ string ] -> shell drv
  #
  # Shorthanded pkgsForSystems w/ mkShell
  #
  hexaShell =
    pkgsForSystems: packages:
      assert isList packages;
      pkgsForSystems (
        pkgs:
        pkgs.mkShellNoCC {
          packages =
            with partition isString packages;
            ( map ( getPackage pkgs ) right ) ++ wrong;
        }
      );

}
