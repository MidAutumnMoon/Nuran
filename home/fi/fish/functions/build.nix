{
  lib,
  callPackage,

  runCommand,
  writeTextFile,
}:


let

  inherit ( lib )
    filter
    hasExtension
    listAllFiles
    ;

  functionFiles = map ( p: writeTextFile {
    name = baseNameOf p;
    text = callPackage p {};
  } ) ( filter (hasExtension ".fish") (listAllFiles ./.) );

in

runCommand "fish-functions" {} ( let

  copy =
    path: '' cp -v -- "${path}" "$out/${lib.getName path}" '';

in ''

  mkdir -p "$out"

  ${ lib.concatStringsSep ";" ( map copy functionFiles ) }

'' )
