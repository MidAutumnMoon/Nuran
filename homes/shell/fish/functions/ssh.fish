function ssh -d 'ssh without kitty'

    set -fx TERM xterm-256color

    command ssh $argv

end
