lib:

let

  inherit (builtins)
    isList
    isPath
    isString
    ;

in

rec {

  # concatPath :: path -> string -> path
  #
  # Wraps parent + "/${name}"
  #
  concatPath =
    parent: childName:
      assert isPath parent;
      assert isPath childName || isString childName;
      parent + "/${childName}";


  # concatPathMap :: path -> [ string ] -> [ path ]
  #
  # Map concatPath on $names.
  #
  concatPathMap =
    parent: childNames:
      assert isPath parent;
      assert isList childNames;
      map (concatPath parent) childNames;

}
