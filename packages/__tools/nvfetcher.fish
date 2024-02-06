#!/usr/bin/env -S fish -PN

#
# Positional script options
#
# 1: path leading to a nvfetcher config file
#
# 2: Github token
#
# 3: (optional) "force" to ignore pins during updating
#

set -l Usage "\
./nvfetcher.fish sources.toml github-token [force]

sources.toml: TOML nvfetcher config
github-token: avoid ratelimiting
[force]: update ignoring \"pinned\" in config\
"

if test ( count $argv ) -lt 1
    echo "Not enough cmdline options"
    exit ( false )
end

set -l Config "$( cat $argv[1] )"

set -l GithubToken "$argv[2]"

set -l ForceMode "$argv[3]"


if test "$GithubToken" = ""
    echo "Need Github token"
    exit ( false )
end



#
# Prepare env
#

set -l FishExe ( status fish-path )

set -l ThisScriptPath ( status filename | path resolve )

set -l SourceDir ( begin
    set -l this_dir ( path dirname -- "$ThisScriptPath" )
    path resolve -- "$this_dir/../__sources"
end )



#
# Enter devshell
#

if not set --query NvfetcherDevshell

    set -lx NvfetcherDevshell ( true )

    nix develop \
        .#nuclage -c "$FishExe" "$ThisScriptPath" $argv

    exit $status

end


if test $ForceMode = "force"

    set Config "$( printf "$Config" | sed '/^pinned/d' )"

end



#
# Remove stale files
#

find "$SourceDir" -mindepth 1 ! -name 'generated.*' -delete



#
# Add Github token
#

set -l Keyfile ( mktemp --suffix ".toml" )
set -l NvfetcherKeyfileOption

printf "%s\n" \
    "[keys]" \
    "github = \"$GithubToken\"" > "$Keyfile"

set -a NvfetcherKeyfileOption "--keyfile" "$Keyfile"



#
# Run nvfetcher
#

set -l NvfetcherExitStatus 0

nvfetcher \
    --config ( printf "$Config" | psub ) \
    --build-dir "$SourceDir" \
    --retry 8 \
    -j 8 \
    $NvfetcherKeyfileOption

set NvfetcherExitStatus $status



#
# Cleanup
#

rm "$Keyfile"

exit $NvfetcherExitStatus
