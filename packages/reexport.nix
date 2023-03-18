{ flakes }:

final: prev:

{

  inherit ( flakes.sops-nix.packages.${ final.system } )
    sops-install-secrets;

}

