function git -d 'heavily overloaded git cli'

    # Goto the project toplevel when no arguments supplied
    test (count $argv) -eq 0
        and begin
            cd -- "$(command git rev-parse --show-toplevel)"
            return $status
        end

    command git $argv

end

