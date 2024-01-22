#!/usr/bin/env -S fish -NP

#
# Helpers
#

function Error
    echo -e $argv 1>&2
    exit ( false )
end

function GuardVar --no-scope-shadowing # dynamic scope
    set -f varname "$argv[1]"
    test -n "$$varname"
    or Error "Envvar \"$varname\" is empty"
end


#
# Grab the whole meta
#

set -l OutputCaddy "$OUTPUT_CADDY" # exported in workflow

GuardVar OutputCaddy

set -l HashMethod "$HASH_METHOD" # exported in workflow

GuardVar HashMethod

set -l Meta "$(
    command nix eval --json \
        .#caddy_teapot.meta \
    2> /dev/null
)"

GuardVar Meta


#
# Grab each caddy related field
#

set -l Version (
    echo $Meta | jq -r '.caddyVer'
)

GuardVar Version

set -l Plugins (
    echo $Meta | jq -r '.caddyPlugins | .[]'
)

GuardVar Plugins

set -l BuildEnv (
    echo $Meta | jq -r '.caddyBuildEnv | .[]'
)

GuardVar BuildEnv


#
# Setup env
#

for env in $BuildEnv
    export "$env"
end


#
# Build
#

set -l WithPlugins (
    for plugin in $Plugins
        echo "--with"
        echo $plugin
    end
)

command xcaddy build $Version \
    --output "$OutputCaddy" \
    $WithPlugins


#
# Finish up
#

set -l Hash (
    $HashMethod $OutputCaddy | awk '{print $1}'
)

echo "caddy_hash=$Hash" >> "$GITHUB_OUTPUT"
echo "caddy_version=$Version" >> "$GITHUB_OUTPUT"