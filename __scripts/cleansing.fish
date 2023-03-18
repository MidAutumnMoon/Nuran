#!/usr/bin/env -S fish -NP

printf "Before cleanup:\n\n%s\n\n%s\n\n" "$(df -h)" "$(free -h)"


# Usage: cleansing.fish <mode>
#
# Since a full blown cleanup takes at least five minutes
# which is too incovenient for frequent or small jobs,
# two modes "light" and "full" are added to address this
# problem.
#
# <mode>:
#
# - light : only remove packages which have processes running
#           to freeup the precious memory
#           There're not too many of them so cleaning don't block
#           CI too long
#
# - full : purge everything not critical to run nix. It' heavy.


if test ( count $argv ) -ne 1
    echo "Expect exact 1 arugment"
    echo "Read this script code for detailed usage"
    exit ( false )
end

set -l CleansingMode "$argv[1]"

if not string match -rq '^(full|light)$' "$CleansingMode"
    echo "Mode \"$CleansingMode\" is wrong"
    echo "Expect \"light\" or \"full\""
    echo "Read this script code for detailed usage"
    exit ( false )
end


set -l BloatedPackagesWithServices \
    '^dotnet.*' \
    'finalrd' \
    'irqbalance' \
    '^libmono.*' \
    '^mono.*' \
    'multipath-tools' \
    '^moby.*' \
    '^packagekit.*' \
    '^php.*' \
    'podman' \
    'sphinxsearch' \
    'snapd' \
    'ufw'

set -l BloatedPackages \
    '^.*-icon-theme' \
    'ant' \
    'apache2' \
    '^aspnetcore.*' \
    'azure-cli' \
    '^bcache.*' \
    'bolt' \
    'brotli' \
    'build-essential' \
    'byobu' \
    '^cpp.*' \
    '^clang.*' \
    'crun' \
    '^emacsen.*' \
    '^firebird.*' \
    '^fonts.*' \
    '^freetds.*' \
    'friendly-recovery' \
    '^gconf.*' \
    '^gfortran.*' \
    'gh' \
    '^gir.*' \
    '^glib.*' \
    '^google.*' \
    '^gsettings.*' \
    '^gtk.*' \
    'htop' \
    '^hunspell.*' \
    'icu-devtools' \
    '^imagemagick.*' \
    '^java.*' \
    '^landscape.*' \
    '^lld.*' \
    '^llvm.*' \
    'man-db' \
    'manpages' \
    '^mecab.*' \
    '^mercurial.*' \
    '^microsoft.*' \
    'motd-news-config' \
    '^msbuild.*' \
    '^mssql.*' \
    '^mysql.*' \
    '^nginx.*' \
    'nuget' \
    'odbcinst' \
    'packages-microsoft-prod' \
    'parallel' \
    'pastebinit' \
    'pollinate' \
    '^postgresql.*' \
    '^r-.*' \
    '^ruby.*' \
    'screen' \
    '^secureboot.*' \
    '^session-.*' \
    'shellcheck' \
    'skopeo' \
    'slirp4netns' \
    'snmp' \
    'subversion' \
    'sosreport' \
    'swig' \
    '^temurin.*' \
    'tmux' \
    'tnftp' \
    '^tex-.*' \
    'texinfo' \
    '^ttf-.*' \
    '^unixodbc.*' \
    '^update-.*' \
    'vim' \
    '^x11.*' \
    'xauth' \
    '^xorg.*' \
    '^upx.*' \
    'xfsprogs' \
    'xorriso' \
    'xtrans-dev' \
    'zerofree' \
    'zsync'

if test $CleansingMode = "light"
    sudo apt purge --yes $BloatedPackagesWithServices
else
    sudo apt purge --yes \
        $BloatedPackages \
        $BloatedPackagesWithServices
end

sudo apt autopurge --yes



set -l BloatedPaths \
    '/usr/share/dotnet' \
    '/usr/share/swift' \
    '/usr/share/miniconda' \
    '/usr/share/gradle' \
    '/usr/share/sbt' \
    '/usr/local/' \
    '/opt/ghc' \
    '/opt/hostedtoolcache' \
    '/opt/pipx' \
    '/opt/powershell' \
    '/var/snap' \
    '/var/cache/' \
    '/var/lib/docker' \
    '/var/lib/mysql' \
    '/var/lib/gems' \
    '/etc/skel'

if not test $CleansingMode = "light"
    for path in $BloatedPaths
        sudo rm -fr "$path" &
    end
end

wait



printf "After cleanup:\n\n%s\n\n%s\n\n" "$(df -h)" "$(free -h)"
