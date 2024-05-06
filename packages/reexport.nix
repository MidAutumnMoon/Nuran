{ flakes }:

final: prev:

let

    inherit ( final )
        system
    ;

    packagesFrom =
        flake: flake.packages.${system};

    selectPackage =
        flake: pname: ( packagesFrom flake ).${pname};

in

with flakes;

{

    inherit ( packagesFrom sops-nix )
        sops-install-secrets
    ;


    stableRustToolchain = let
        inherit ( packagesFrom fenix )
            stable
            targets
            combine
        ;
        musl = targets.x86_64-unknown-linux-musl;
    in combine [
        stable.rustc
        stable.cargo
        musl.stable.rust-std
    ];

}

