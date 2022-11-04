function cp

    status is-interactive
        and set -f flags '--interactive'

    command cp $flags $argv

end
