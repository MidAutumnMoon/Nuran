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

}

