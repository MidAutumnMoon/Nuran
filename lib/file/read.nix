lib:

let

  inherit ( builtins )
    all
    isPath isString
    readFile
    concatStringsSep
    ;

  inherit ( lib.nuran.path )
    isDir listAllFiles
    ;

in

rec {

  # readSomeFiles :: string -> [ path ] -> string
  #
  # Join content of files together using $separator.
  #
  readSomeFiles =
    separator: files:
      assert isString separator;
      assert all isPath files;
      concatStringsSep separator ( map readFile files );


  # readAllFiles :: path -> string
  #
  # Find and read all files in $toplevel,
  # then join them using $separator.
  #
  readAllFiles =
    separator: toplevel:
      assert isString separator;
      assert isDir toplevel;
      readSomeFiles separator ( listAllFiles toplevel );

}
