{
  lib,
  runCommandLocal,

  derputils,
}:

toplevel:


let

  name =
    "home-fish-${ baseNameOf toplevel }";

  buildEnv.nativeBuildInputs = [
      derputils
    ];

  buildScript = ''
    find ${ toplevel } \
      -type f \
      -name '*.fish' \
      -exec fcombine "$out" {} \+
    '';

in

runCommandLocal name buildEnv buildScript
