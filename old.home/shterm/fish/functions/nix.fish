{}: ''

function nix -d 'overloaded nix cli'

    # There're arguments, so run nix normally.

    if test ( count $argv ) -gt 0
        command nix $argv
        return $status
    end


    # There's no arguments, so cd to Nuran.

    if set --query Nuran
        cd -- "$Nuran"
        return $status
    end


    # If the location of Nuran isn't defined,
    # while, let nix do its thing.

    command nix

end

''
