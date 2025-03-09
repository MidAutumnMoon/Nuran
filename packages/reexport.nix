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

{

    inherit ( packagesFrom flakes.sops-nix )
        sops-install-secrets
    ;

    inherit ( packagesFrom flakes.colmena )
        colmena
    ;

}

