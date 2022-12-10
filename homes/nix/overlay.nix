{ flake, ... }:

{

  xdg.configFile."nixpkgs/overlays.nix".text = ''
    ( builtins.getFlake "${flake.nuclage}" ).totalOverlays
    '';

}
