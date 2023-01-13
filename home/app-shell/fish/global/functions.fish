functions --erase ls

function ls
    set --function flags

    status is-interactive
        and set flags \
            '--group-directories-first' \
            '--color=tty' \
            '--human-readable'

    command ls $flags $argv
end


functions --erase fish_command_not_found
