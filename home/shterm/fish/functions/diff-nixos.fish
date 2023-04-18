{ ... }: ''

function diff-nixos

    command nix profile diff-closures --profile '/nix/var/nix/profiles/system'

end

''
