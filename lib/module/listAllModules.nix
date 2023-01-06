lib:

let

  inherit ( builtins )
    filter
    ;

  inherit ( lib.nuran.path )
    isDir
    listAllDirs
    ;

  inherit ( lib.nuran.module )
    isModule
    ;

in

{


  # listAllModules :: path -> [ path ]
  #
  # List the path of folders which isModule.
  #
  listAllModules =
    toplevel:
      assert isDir toplevel;
      filter isModule ( listAllDirs toplevel );

}
