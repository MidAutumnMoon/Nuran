lib:

let

  inherit ( lib )
    isPath
    pathExists
    ;

in

{

    # isModule :: path -> bool
    #
    # A module is a directory who has
    # a default.nix. Files are just modules.
    #
    isModule =
      path: isPath path && pathExists ( path + "/default.nix" );

}
