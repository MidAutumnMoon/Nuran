{ flakes, ... }:

{

  xdg.configFile."nixpkgs/overlays.nix".text = ''
    if builtins ? getFlake then
      ( builtins.getFlake "${flakes.nuclage}" ).totalOverlays
    else
      []
    '';

}
