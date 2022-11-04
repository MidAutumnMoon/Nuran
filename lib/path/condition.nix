lib:

let

  inherit (builtins)
    isPath
    pathExists
    toString
    ;

in

rec {

  # isModule :: path -> bool
  #
  # A module is a directory who has
  # a default.nix. Files are just modules.
  #
  isModule =
    path: isPath path && pathExists (path + "/default.nix");


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
