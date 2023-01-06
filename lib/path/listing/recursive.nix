lib:

let

  inherit ( builtins )
    attrNames
    concatMap
    readDir
    ;

  inherit ( lib.nuran.path )
    isDir
    ;


  # listDirNames :: path -> [ string ]
  listDirNames =
    parent:
      let children = readDir parent; in
      concatMap ( name:
        if children.${ name } == "directory" then
          [ name ]
        else
          []
      ) ( attrNames children );

  # listDirs :: path -> [ path ]
  listDirs =
    toplevel:
      map ( path: toplevel + ( "/" + path ) ) ( listDirNames toplevel );


  # _listAllDirs :: path -> [ path ]
  #
  # Raw "listAllDirs" without type checking
  # to increase the speed.
  #
  _listAllDirs =
    toplevel:
      let subdirs = listDirs toplevel; in
      if subdirs == []
      then [ toplevel ]
      else [ toplevel ] ++ ( concatMap _listAllDirs subdirs );

in

{

  # listAllDirs :: path -> [ path ]
  #
  # Traverse the $toplevel from up to bottom
  # and find every directories under it.
  #
  # Benchmark: 180ms runs on whole nixpkgs,
  # with kernel 6.1 & btrfs. Not too shabby :)
  #
  listAllDirs =
    toplevel:
      assert isDir toplevel;
      _listAllDirs toplevel;


  # listAllFiles :: path -> [ path ]
  #
  # Walk through $toplevel and list every regular files.
  #
  listAllFiles =
    toplevel:
      assert isDir toplevel;
      lib.filesystem.listFilesRecursive toplevel;

}
