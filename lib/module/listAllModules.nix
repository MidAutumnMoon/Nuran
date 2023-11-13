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
    # Alllll the modules.
    #
    listAllModules = entry:
      assert isDir entry;
      filter isModule ( listAllDirs entry );

}
