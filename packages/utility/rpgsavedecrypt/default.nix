{
  lib,
  runCommand,
  substituteAll,

  python3,
}:

let

  pythonWithDeps =
    python3.withPackages ( p: [ p.lzstring ] );

  interpreter =
    lib.getExe pythonWithDeps;

  pname = "rpgsavedecrypt";

in

runCommand pname {

  script = substituteAll {
    src = ./main.py;
    inherit interpreter;
  };

  meta.mainProgram = pname;

} ''

install -Dm755 "$script" "$out/bin/${pname}"

''
