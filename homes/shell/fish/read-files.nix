{ lib
, runCommandLocal

, toplevel
}:

assert builtins.isPath toplevel;

runCommandLocal "fish-read-files" {} ''
  find ${toplevel} \
    -type f \
    -iname '*.fish' \
    -exec cat '{}' \+ \
  > "$out"
  ''
