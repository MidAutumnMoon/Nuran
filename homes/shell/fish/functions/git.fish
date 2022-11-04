function git -d 'heavily overloaded git cli'

    set -f Git '@git@'


    # goto the project toplevel if no arguments
    # was supplied
    test (count $argv) -eq 0
    and begin
        cd -- "$(command $Git rev-parse --show-toplevel)"
        return $status
    end


    # if not inside a git repo, go Unstashed shortcut
    # instead
    not command $Git rev-parse --is-inside-work-tree 1> /dev/null 2>&1
    and test -f "$(pwd)/.gitignore"
    and begin
        command $Git \
            --git-dir "$UNSTASHED_TOPLEVEL" \
            --work-tree "$HOME" \
            $argv
        return $status
    end


    command $Git $argv

end

