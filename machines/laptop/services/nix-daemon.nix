{ lib, ... }:

{

  # Not enough memory :(
  nix.settings.cores = lib.mkForce 8;

}
