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
# 2) Verify
#

sudo systemctl daemon-reload
sudo systemctl restart nix-daemon

systemctl cat nix-daemon
