{ config, ... }:

let

  inherit (config.home)
    homeDirectory
    ;

  inherit (config.xdg)
    cacheHome configHome dataHome
    ;

in

{

  home.sessionVariables = {

      # nix configs

      NIXPKGS_ALLOW_UNFREE = 1;


      # Firefox things

      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";


      # Leftovers

      NURAN_TOPLEVEL =
        "${homeDirectory}/Nix";

      Nuclage =
        "${ homeDirectory }/Project/Nix/Nuclage";

    };

}
