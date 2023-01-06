lib:

let

  inherit ( builtins )
    isPath
    pathExists
    toString
    ;

in

rec {

  # isDir:: path -> bool
  #
  # A filesystem trick is used.
  #
  isDir =
    path: isPath path && pathExists ( (toString path) + "/." );


  # isFile :: path -> bool
  #
  # Symlinks are dirs or files ultimately.
  #
  isFile =
    path: isPath path && pathExists path && ! ( isDir path );

}
