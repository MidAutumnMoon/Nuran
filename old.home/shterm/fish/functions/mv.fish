{}: ''

function mv

    status is-interactive
        and set -f flags '--interactive'

    command mv $flags $argv

end

''
