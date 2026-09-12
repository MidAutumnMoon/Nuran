# The first-party Rust workspace.
#
# Every directory shipping a default.nix is a workspace member packaged
# into the `tsuki` namespace; anything else (cargo's target/) is
# plumbing.
{
    lib,
    callPackage,
}:

let

    inherit (lib.fileset)
        unions toSource intersection gitTracked;
    inherit (lib.path) append;

    tracked = gitTracked ./.;
    manifest = append ./. "Cargo.toml";
    lock = append ./. "Cargo.lock";

    # A source tree holding only the named workspace members beside the
    # root manifests, so a crate rebuilds when its own sources or the
    # manifests change — never because a sibling did. Members missing
    # from the tree are pruned from the lockfile copy by cargo itself
    # during the build.
    selectSrc = members: toSource {
        root = ./.;
        fileset = intersection tracked <| unions (
            [ manifest lock ] ++ map (append ./. ) members
        );
    };

    workspace = {
        cargoLock.lockFile = lock;
        inherit selectSrc;
    };

    members = lib.filterAttrs
        (name: type:
            type == "directory"
            && builtins.pathExists (./. + "/${name}/default.nix"))
        (builtins.readDir ./.);

in

lib.mapAttrs
    (name: _: callPackage ./${name} { inherit workspace; })
    members
