#!/usr/bin/env -S fish -NP


#
# 1) Set TMPDIR for nix
#

set --local NewBuildDir "/nixbuild"

set --local OverrideDir "/etc/systemd/system/nix-daemon.service.d"
set --local OverrideConf "$OverrideDir/99-tmpdir.conf"


for dir in "$NewBuildDir" "$OverrideDir"
    sudo mkdir --parent "$dir"; or exit $status
end

set --local Conf \
    "[Service]" \
    "Environment=TMPDIR=$NewBuildDir"

for line in $Conf
    echo "$line" | sudo tee --append "$OverrideConf"
end



#
# 2) Set GitHub PAT to avoid rate limiting
#

set --local NixConf "/etc/nix/nix.conf"

set --query GITHUB_TOKEN
    or begin
        echo 'Required env GITHUB_TOKEN not set'
        exit 1
    end

sudo sed --in-place --expression \
    "\$aaccess-tokens = github.com=$GITHUB_TOKEN" \
    "$NixConf"



#
# 3) Verify
#

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

systemctl cat nix-daemon

grep -i --quiet "$GITHUB_TOKEN" "$NixConf"
    and echo "PAT hopefully set"

