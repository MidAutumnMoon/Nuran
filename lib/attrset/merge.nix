lib:

let

  inherit (builtins)
    all
    isAttrs
    ;

in

{

  # mergeListOfAttrs :: [ attr ] -> attr
  #
  # Merge a list of attrset together.
  #
  mergeListOfAttrs =
    attrsetList:
      assert all isAttrs attrsetList;
      lib.foldl lib.recursiveUpdate { } attrsetList;

}
