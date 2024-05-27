{ lib, pkgs, }: ''

function quick7z

    if test ( count $argv ) -ne 1
        echo "Wrong number of options"
        return ( false )
    end

    set -f Origin "$argv[1]"
    set -f Basename ( path basename -- "$Origin" )
    set -f Target "$Basename.7z"

    command '${lib.getExe pkgs.p7zip}' a -m0=lzma2 -mx=7 -ms=on "$Target" "$Origin"

end

''
