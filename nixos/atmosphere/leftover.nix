{ lib, ... }:

{

  system.stateVersion = lib.trivial.release;

  documentation.nixos.enable = false;

}
