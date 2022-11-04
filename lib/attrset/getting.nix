lib:

{

  # getAttrsByValue :: anything -> attrset -> attrset
  #
  # Get attrset items who have $value.
  #
  getAttrsByValue =
    valueToFind: attrset:
      assert builtins.isAttrs attrset;
      lib.filterAttrs (_: value: value == valueToFind) attrset;

}
