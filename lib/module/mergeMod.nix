lib:

let

  inherit ( builtins ) isList;

in

{

  # mergeMod :: [ module ] -> attrset
  #
  # Wrapper of the `imports` in module system.
  #
  mergeMod =
    modules:
      assert isList modules;
      { imports = modules; };

}
