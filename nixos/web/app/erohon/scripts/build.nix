{ runCommandLocal
, fd
, ruby_3
}:

let

  buildEnv =
    { nativeBuildInputs =
        [ fd ];
      buildInputs =
        [ ruby_3 ];
    };

in

runCommandLocal "h-scripts" buildEnv ''

  mkdir --parent "$out"

  fd . ${./.} \
    --type executable \
    --exec-batch cp --target-directory "$out"

  patchShebangs "$out"

''
