lib:

let

  inherit (lib.nuran.path)
    isDir
    isModule
    listAllDirs
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
      builtins.filter isModule (listAllDirs toplevel);

}
