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

  home.sessionVariables =
    {
      # nix configs

      NIXPKGS_ALLOW_UNFREE = 1;


      # Firefox things

      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";


      # Leftovers

      NURAN_TOPLEVEL =
        "${homeDirectory}/Nix";

      UNSTASHED_TOPLEVEL =
        "${homeDirectory}/Project/Unstashed";


      # Advises from github:b3nj5m1n/xdg-ninja

      KDEHOME =
        "${configHome}/kde";

      XCOMPOSEFILE =
        "${configHome}/X11/xcompose";
      XCOMPOSECACHE =
        "${cacheHome}/X11/xcompose";

      HISTFILE =
        "${cacheHome}/bash/history";

      PYTHONSTARTUP =
        "${configHome}/python/pythonrc";

      LESSHISTFILE =
        "${cacheHome}/less/history";

      CARGO_HOME =
        "${cacheHome}/cargo";

      _JAVA_OPTIONS =
        "-Djava.util.prefs.userRoot=${configHome}/java";
    };

}
