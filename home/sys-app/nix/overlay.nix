{ flakes, ... }:

{

  xdg.configFile."nixpkgs/overlays.nix".text = ''
    with builtins;
    if builtins ? getFlake then
      attrValues ( getFlake "${ flakes.self }" ).overlays
    else
      []
    '';

}
