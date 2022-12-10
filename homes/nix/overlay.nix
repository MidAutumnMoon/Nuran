{ flakes, ... }:

{

  xdg.configFile."nixpkgs/overlays.nix".text = ''
    ( builtins.getFlake "${flakes.nuclage}" ).totalOverlays
    '';

}
