lib:

let

  inherit (builtins)
    attrNames
    readDir
    ;

  inherit (lib.nuran.attrset)
    getAttrsByValue
    ;

  inherit (lib.nuran.path)
    isDir
    concatPathMap
    ;


  # _listingByType :: string -> path -> [ string ]
  #
  _listingByType =
    type: toplevel:
      assert isDir toplevel;
      attrNames ( getAttrsByValue type (readDir toplevel) );

in

rec {

  # :hidden: listDirsNames :: path -> [ string ]
  #
  # List names of directories under $toplevel.
  #
  listDirsNames =
    _listingByType "directory";


  # :hidden: listFilesNames :: path -> [ string ]
  #
  # Lists names of files.
  #
  listFilesNames =
    _listingByType "regular";


  # listDirs :: path -> [ path ]
  #
  # List directories inside one directory.
  #
  listDirs =
    toplevel:
      concatPathMap toplevel (listDirsNames toplevel);


  # listFiles :: path -> [ path ]
  #
  # List regular files inside one directory.
  #
  listFiles =
    toplevel:
      concatPathMap toplevel (listFilesNames toplevel);

}
