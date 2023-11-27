#!/usr/bin/env -S fish -NP

#
# Arguments:
#
# - $1 : nix source file contains an attrset
# - $2 : a name in that attrset which contains a list of drvs
#

set --local AttrsetFile "$( path resolve "$argv[1]" )"
set --local DrvListName "$argv[2]"


if test ( count $argv ) != 2
    echo "Wrong number of arguments, expecting 2."
    exit ( false )
end

if test -z "$AttrsetFile" || test -z "$DrvListName"
    echo "Invalid arguments."
    echo 'Either $AttrsetFile or $DrvListName is empty.'
    exit ( false )
end

if not test -f "$AttrsetFile"
    echo "$AttrsetFile not found."
    exit ( false )
end


command nix build --file "$AttrsetFile" \
    "$DrvListName" \
    --print-build-logs \
    --option narinfo-cache-negative-ttl 0 \
    --option keep-going true \
    --option max-jobs 3
