function quick7z

    if test ( count $argv ) -ne 1
        echo "Wrong number of options"
        return ( false )
    end

    set -f Origin "$argv[1]"
    set -f Basename ( path basename -- "$Origin" )
    set -f Target "$Basename"

    command 7z a -m0=lzma2 -mx=7 -ms=on "$Target" "$Origin"

end

