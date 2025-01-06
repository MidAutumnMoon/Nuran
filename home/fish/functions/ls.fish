{ lib, eza, }: ''

function ls

    command ${lib.getExe eza} \
        '--group-directories-first' \
        '--color=auto' \
        '--sort=name' \
        '--smart-group' \
        $argv

end

''
