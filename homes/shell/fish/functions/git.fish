function git -d 'heavily overloaded git cli'

    set -f Git '@git@'

    # Goto the project toplevel when no arguments supplied
    test (count $argv) -eq 0
        and begin
            cd -- "$(command $Git rev-parse --show-toplevel)"
            return $status
        end

    command $Git $argv

end

