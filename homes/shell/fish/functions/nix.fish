function nix -d 'overloaded nix cli'

    # There're arguments, so run nix normally.

    test (count $argv) -gt 0
        and begin
            command nix $argv
            return $status
        end


    # There's no arguments, so cd to Nuran.

    set --query NURAN_TOPLEVEL
        and begin
            cd -- "$NURAN_TOPLEVEL"
            return $status
        end


    # If the location of Nuran isn't defined,
    # while, let nix do its thing.

    command nix

end
