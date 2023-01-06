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


  # _mergeListOfAttrs :: [ attrset ] -> attrset
  #
  _mergeListOfAttrs =
    builtins.foldl' ( a: b: a // b ) { };

  # _readLibFuncs :: path -> [ (attrset -> attrset) ]
  #
  _readLibFuncs =
    libDir: map import ( import libDir );

  # _applySelf :: (attrset -> attrset) -> attrset
  #
  _applySelf =
    libFunc: libFunc self;

  # callLib :: path -> attrset
  #
  callLib =
    libDir: _mergeListOfAttrs ( map _applySelf (_readLibFuncs libDir) );

in

rec {

  nuran.attrset  = callLib ./attrset;
  nuran.path     = callLib ./path;
  nuran.file     = callLib ./file;
  nuran.flake    = callLib ./flake;
  nuran.nixos    = callLib ./nixos;
  nuran.trivial  = callLib ./trivial;
  nuran.language = callLib ./language;
  nuran.nixpkgs  = callLib ./nixpkgs;


  inherit (nuran.attrset)
    mergeListOfAttrs getAttrsByValue
    ;

  inherit (nuran.path)
    isDir isFile
    listAllFiles listAllDirs
    ;

  inherit (nuran.file)
    readSomeFiles readAllFiles
    ;

  inherit (nuran.flake)
    importNixpkgs hexaShell
    mkSystems
    ;

  inherit (nuran.nixos)
    isModule
    flatMod condMod
    listAllModules
    ;

  inherit (nuran.trivial)
    doNothing
    onceride oncerideDrv
    ;

  inherit (nuran.language)
    readVersionCargo
    ;

  inherit (nuran.nixpkgs)
    removePatches
    ;

}
