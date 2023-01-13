abbr -a n nix

set --local __cmd_common 'sudo nixos-rebuild --print-build-logs --flake .%'

abbr -a --set-cursor rs "$__cmd_common switch"
abbr -a --set-cursor rb "$__cmd_common boot"
abbr -a --set-cursor rt "$__cmd_common test"

abbr -a --set-cursor rbd 'nixos-rebuild --print-build-logs --flake .% build'
