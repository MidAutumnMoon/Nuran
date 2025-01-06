{ config, ... }:

let

    inherit ( config.xdg )
        dataHome
        cacheHome
        configHome
        stateHome
    ;

in

{

    xdg.enable = true;

    # TODO: generate the path from corresponding variables.
    systemd.user.tmpfiles.rules = [
        "d ${stateHome}/bash - - - - -"
        "d ${stateHome}/less - - - - -"
        "d ${cacheHome}/X11 - - - - -"
        "d ${configHome}/X11 - - - - -"
    ];

    home.sessionVariables = {
        HISTFILE = "${stateHome}/bash/history";
        LESSHISTFILE = "${stateHome}/less/history";
        SQLITE_HISTORY = "${cacheHome}/sqlite_history";

        CARGO_HOME = "${dataHome}/cargo";
        RUSTUP_HOME = "${dataHome}/rustup";

        XCOMPOSEFILE = "${configHome}/X11/xcompose";
        XCOMPOSECACHE = "${cacheHome}/X11/xcompose";

        CUDA_CACHE_PATH = "${cacheHome}/nv";
        __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nv";
    };

}
