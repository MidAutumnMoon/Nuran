{}: ''

function git -d 'heavily overloaded git cli'

    # Goto the project toplevel when no arguments supplied
    if test ( count $argv ) -eq 0
        cd -- "$( command git rev-parse --show-toplevel )"
        return $status
    end

    command git $argv

end

''
