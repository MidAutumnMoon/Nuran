lib:

let

  inherit ( lib )
    elem
    filter
    getName
    isDerivation
    isPath
    isList
    ;


  # identify :: whatever -> string
  identify =
    whatever:
      if isPath whatever then
        baseNameOf whatever
      else if isDerivation whatever then
        getName whatever
      else
        "";

in

{

  # removePatches :: [string] -> [path | drv] -> [path | drv]
  #
  # Remove patches from $allPatches whose name/pname (if it's drv)
  # or basename (if it's a path) is in $badPatches.
  #
  removePatches =
    badPatches: allPatches:
      assert isList badPatches;
      assert isList allPatches;
      filter ( patch: ! elem ( identify patch ) badPatches) allPatches;

}
