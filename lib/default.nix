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

  importParts =
    dir: map import ( import dir );

  importLib =
    dir: mergeListOfAttrs ( map ( f: f lib ) ( importParts dir ) );

in

rec {

  nuran.path     = importLib ./path;
  nuran.file     = importLib ./file;
  nuran.module   = importLib ./module;
  nuran.trivial  = importLib ./trivial;
  nuran.nixpkgs  = importLib ./nixpkgs;

  inherit ( nuran.path )
    isDir isFile
    listAllFiles listAllDirs
    ;

  inherit ( nuran.file )
    readSomeFiles readAllFiles
    ;

  inherit ( nuran.module )
    isModule
    flatMod condMod mergeMod
    listAllModules
    ;

  inherit ( nuran.trivial )
    doNothing
    assembleSystem
    ;

  inherit ( nuran.nixpkgs )
    removePatches
    onceride oncerideDrv
    brewNixpkgs
    brewShells
    ;

}
