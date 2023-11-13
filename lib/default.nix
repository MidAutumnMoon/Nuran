self: super:

let

    # Each single lib is a file contains
    # a list of paths to more files each of
    # which is a function that accepts one
    # argument, the lib fixed-point itself,
    # and returns a attrset of something.
    #
    # Then the list of returned attrset
    # is got foldl-ed using '//'.

    lib = self;

    mergeListOfAttrs =
        builtins.foldl' ( a: b: a // b ) {};

    importParts = dir: map import ( import dir );

    activateLib =
        dir: mergeListOfAttrs ( map ( f: f lib ) ( importParts dir ) );

in

rec {

    nuran.path     = activateLib ./path;
    nuran.module   = activateLib ./module;
    nuran.string   = activateLib ./string;
    nuran.trivial  = activateLib ./trivial;
    nuran.nixpkgs  = activateLib ./nixpkgs;

    inherit ( nuran.path )
        isDir
        listAllFiles listAllDirs
        hasExtension
    ;

    inherit ( nuran.module )
        isModule
        flatMod condMod
        listAllModules
    ;

    inherit ( nuran.string )
        capitalize
    ;

    inherit ( nuran.trivial )
        doNothing
        assembleSystem
        adoptColmena
    ;

    inherit ( nuran.nixpkgs )
        removePatches
        onceride oncerideDrv
        brewNixpkgs
        brewShells
    ;

}
