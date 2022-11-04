lib:

let

  inherit (builtins)
    all isString;

in

{

  # hexaShell :: (pkgs as of ./import.nix) -> [ string ] -> shell drv
  #
  # Shorthanded pkgsForSystems + mkShell
  #
  hexaShell =
    pkgsForSystems: packageNames:
      assert all isString packageNames;
      pkgsForSystems ( pkgs:
        pkgs.mkShellNoCC
          { packages = map (name: pkgs.${name}) packageNames; }
      );


}
