{ config, ... }:

let

  inherit (config.xdg)
    cacheHome
    configHome
    stateHome
    ;

in

{

  xdg.enable = true;


  systemd.user.tmpfiles.rules = [
      "d ${stateHome}/bash - - - - -"
      "d ${stateHome}/less - - - - -"
      "d ${cacheHome}/X11 - - - - -"
      "d ${configHome}/X11 - - - - -"
    ];


  home.sessionVariables = {

      HISTFILE = "${stateHome}/bash/history";
      LESSHISTFILE = "${stateHome}/less/history";
      CARGO_HOME = "${cacheHome}/cargo";

      XCOMPOSEFILE = "${configHome}/X11/xcompose";
      XCOMPOSECACHE = "${cacheHome}/X11/xcompose";
      SOLARGRAPH_CACHE = "${cacheHome}/solargraph";

      CUDA_CACHE_PATH = "${cacheHome}/nv";
      __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nv";

    };

}
