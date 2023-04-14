#!/usr/bin/env -S fish -NP

# Arguments:
#
# - $1 : the file contains an attrset
# - $2 : a name in that attrset which contains a list of drvs
#

set --local AttrsetFile "$( path resolve "$argv[1]" )"
set --local DrvListName "$argv[2]"


#
# Checks
#

test ( count $argv ) != 2
    and begin
        echo "Wrong number of arguments, expecting 2."
        exit 1
    end

test "$AttrsetFile" = "" || test "$DrvListName" = ""
    and begin
        echo "Invalid arguments."
        echo "Either \$AttrsetFile or \$DrvListName is empty."
        exit 1
    end

test -f "$AttrsetFile"
    or begin
        echo "$AttrsetFile not found."
        exit 1
    end

command nix eval --impure --json \
        --expr "( import \"$AttrsetFile\" ).\"$DrvListName\"" 1> /dev/null
    or begin
        echo "Selected name \"$DrvListName\" not exists."
        echo "Or nix failed while evaluating \"$AttrsetFile\"."
        exit 1
    end

set --local BuildFlags \
    '--print-build-logs' \
    '--option' 'narinfo-cache-negative-ttl' '0' \
    '--option' 'keep-going' 'true' \
    '--option' 'max-jobs' '3'

command nix build \
    --file "$AttrsetFile" \
    "$DrvListName" \
    $BuildFlags
