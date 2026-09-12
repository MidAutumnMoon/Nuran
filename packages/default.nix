{ lib, flakes }:

final: prev:

let

    callPackage = final.newScope {
        inherit lib flakes;
    };

    hostSystem = final.stdenv.hostPlatform.system;

    pkgsFrom =
        name: flakes.${name}.packages.${hostSystem};

    legacyFrom =
        name: flakes.${name}.legacyPackages.${hostSystem};

    # Store-path pins; see ./__pin/.
    pinned = import ./__pin/pins.nix {
        system = hostSystem;
    };

    discovered =
        lib.packagesFromDirectoryRecursive {
            inherit callPackage;
            directory = ./.;
        };

in rec {

    tsuki = discovered // {

        # First-party crates from the Rust workspace; see ../rust.
        __ci = callPackage ../rust/__ci {};
        __pin = callPackage ../rust/__pin {};
        localbinbox = callPackage ../rust/localbinbox {};
        maintenance = callPackage ../rust/maintenance {};
        mimic-cloud-init = callPackage ../rust/mimic-cloud-init {};
        psd-rs = callPackage ../rust/psd-rs {};
        system76-scheduler-niri = callPackage ../rust/system76-scheduler-niri {};

        # test builds
        portableTest = callPackage ./portable/test.nix {};

        kde = callPackage ./kde/package.nix {
            kdePackages = prev.kdePackages;
        };

        inherit pinned;

        # Using lib.fileset to avoid unnecessary non-rust rebuilds.
        workspace =
            let
                inherit (lib.fileset)
                    unions toSource intersection gitTracked;
                inherit (lib.path) append;

                rust = ../rust;
                tracked = gitTracked rust;
                manifest = append rust "Cargo.toml";
                lock = append rust "Cargo.lock";

                # A source tree holding only the named workspace members
                # beside the root manifests, so a crate rebuilds when its
                # own sources or the manifests change — never because a
                # sibling did. Members missing from the tree are pruned
                # from the lockfile copy by cargo itself during the build.
                selectSrc = members: toSource {
                    root = rust;
                    fileset = intersection tracked <| unions (
                        [ manifest lock ] ++ map (append rust) members
                    );
                };
            in {
                cargoLock.lockFile = lock;
                inherit selectSrc;
            };
    };

    inherit (pkgsFrom "sops-nix")
        sops-install-secrets
    ;

    inherit (pinned)
        omp
        zcode
    ;

    linuxCachyos = tsuki.cachyos.linuxPackages;

    # tangled = {
    #     inherit (pkgsFrom "tangled")
    #         knot
    #     ;
    # };

    dnscrypt-proxy = tsuki.dnscrypt;

    obsidian = lib.useElectronBin prev prev.obsidian;

    navidrome = prev.navidrome.overrideDerivation (old: {
        CGO_CFLAGS_ALLOW = "--define-prefix";
    });

    yt-dlp = prev.yt-dlp.override {
        inherit (tsuki) deno;
    };

    zram-generator =
        lib.onceride prev.zram-generator
        { rustPlatform = tsuki.rust; }
        { doCheck = false; }; # tests fail on github workflow

    sudo-rs =
        lib.onceride prev.sudo-rs
        { rustPlatform = tsuki.rust; }
        { doCheck = false; }; # tests fail on github workflow

    kdePackages = tsuki.kde;

    #
    # Lix overrides
    #

    lixSet = prev.lixPackageSets.latest;

    inherit (lixSet)
        lix
        # The default "lix" points to old stable version
        nix-eval-jobs
    ;

    nixVersions = prev.nixVersions // {
        stable = lixSet.lix;
        latest = lixSet.lix;
    };

    nixForLinking = prev.nixVersions.stable;

    nix-direnv =
        prev.nix-direnv.override { nix = final.lix; };

}
