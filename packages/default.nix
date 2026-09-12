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

    # Store-path pins; see ../rust/__pin/pins.nix.
    pinned = import ../rust/__pin/pins.nix {
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
                inherit (lib.strings) hasInfix;
                rust = ../rust;
                workspaceRootToml = append rust "Cargo.toml";
                workspaceLock = append rust "Cargo.lock";
                membersSrc =
                    lib.importTOML workspaceRootToml
                    |> (m: m.workspace.members)
                    # assert that "members" does not contains glob
                    |> (ms:
                        assert lib.all (m: !hasInfix m "*") ms;
                        ms)
                    |> map (append rust);
                workspaceSrc = unions <|
                    [ workspaceRootToml workspaceLock ]
                    ++ membersSrc;
            in {
                cargoLock.lockFile = workspaceLock;
                src = toSource {
                    root = rust;
                    fileset = intersection
                        (gitTracked rust) workspaceSrc;
                };
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
