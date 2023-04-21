{ flakes }:

final: prev:

let

  inherit ( final ) system;

in

{

  inherit ( flakes.sops-nix.packages.${system} )
    sops-install-secrets;

  colmena_git =
    flakes.colmena.packages.${system}.colmena;

}

