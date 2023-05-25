{ flakes }:

final: prev:

let

  inherit ( final ) system;

  packagesFrom =
    flake: flake.packages.${system};

  selectPackage =
    flake: pname: ( packagesFrom flake ).${pname};

in

with flakes;

{

  inherit ( packagesFrom sops-nix )
    sops-install-secrets;

  colmena_git =
    selectPackage colmena "colmena";

  nil =
    selectPackage nil-lsp "nil";

  nvfetcher_git =
    selectPackage nvfetcher "default";

}

