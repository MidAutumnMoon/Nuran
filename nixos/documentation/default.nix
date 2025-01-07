{ pkgs, config, lib, ... }:

lib.mkMerge [

{

    documentation.info.enable = false;
    documentation.nixos.enable = false;

}

( let

    inherit ( pkgs.writers )
        writeFish
    ;

    cfg = config.documentation.man.man-db;

    # Ref: nixpkgs/ecfe591593fa74:modules/misc/man-db.nix#L92C52-L92C72
    cachePath = "/var/cache/man/nixos";

in lib.mkIf ( cfg.enable ) {

    # We generate the cache ourselves.
    documentation.man.generateCaches = false;

    systemd.services."man-db" = {
        requires = [ "sysinit-reactivation.target" ];
        after = [ "sysinit-reactivation.target" ];
        partOf = [ "sysinit-reactivation.target" ];
        wantedBy = [ "default.target" ];
        path = [
            cfg.package
            pkgs.gawk
        ];
        # Upstream config
        serviceConfig = {
            Nice = 19;
            IOSchedulingClass = "idle";
            IOSchedulingPriority = 7;
        };

        # Here, it is essentially implementing content-addresse man-db cache.
        serviceConfig.ExecStart = writeFish "mandbsvc" /*fish */ ''
            set -l SystemManLoc "/run/current-system/sw/share/man"
            set -l ContentRecord "${cachePath}/man-db-state"

            if [ ! -d "${cachePath}" ]
                mkdir -pv "${cachePath}" || exit 1
            end

            if [ ! -f "$ContentRecord" ]
                touch "$ContentRecord" || exit 1
            end

            # 1) Collect list of all manpage files and calculate hashes
            # of them
            #
            # man1/ls.1.gz
            # man3/func.3.gz
            #
            # hash ->
            #
            # bbbbbbbbbbbb (man1/ls.1.gz)
            # aaaaaaaaaaaa (man3/func.3.gz)
            set -l hashes "$(
                find -L "$SystemManLoc" -type f -iname "*.gz" \
                    -exec sha256sum "{}" "+" \
                | awk '{ print $1 }'
                or exit 1
            )"

            # 2) Sort the hashes to make them "stable",
            # and then join them toghther into a big long string,
            # and then hash this big string to get the hash of the directory
            #
            # bbbbbbbbbbbb
            # aaaaaaaaaaaa
            #
            # sort ->
            #
            # aaaaaaaaaaaa
            # bbbbbbbbbbbb
            #
            # join ->
            #
            # aaaaaaaaaaaabbbbbbbbbbbb
            #
            # hash ->
            #
            # cccccccccccc
            set -l ultimate_hash (
                echo $hashes \
                | sort \
                | string join "" \
                | sha256sum - \
                | awk '{ print $1 }'
                or exit 1
            )

            set -l old_hash "$( string collect < "$ContentRecord" )"

            echo "Old hash: $old_hash"
            echo "New hash: $ultimate_hash"

            if [ "$old_hash" != "$ultimate_hash" ]
                echo "Hash changed, do a full man-db rebuild"
                mandb -psc || exit 1
                echo "Write new hash"
                echo "$ultimate_hash" > "$ContentRecord"
            else
                echo "Hash not changed, skip"
            end
        '';
    };

} )

]
