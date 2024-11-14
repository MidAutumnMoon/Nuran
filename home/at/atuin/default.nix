{ lib, pkgs, config, ... }:

lib.mkMerge [

{ programs.atuin = {

    enable = true;

    enableFishIntegration = false;

    settings = {
        enter_accept = true;
        search_mode = "fulltext";
        style = "compact";
        invert = true;
        inline_height = 20;
        show_tabs = false;
        show_help = false;
        prefers_reduced_motion = true;
    };

}; }

( let

    runAtuin = name: cmd:
        let atuin = config.programs.atuin.package; in
        # idoit atuin tries to create .config/atuin and fails
        # in homeless-shelter
        pkgs.runCommandNoCC name { buildInputs = [ atuin ]; } ''
            export HOME=$( mktemp -d )
            ${cmd}
        '';

    atuin_init = runAtuin "atuin_init"
        "atuin init fish > $out";

    atuin_comp = runAtuin "atuin_comp"
        "atuin gen-completions --shell fish > $out";

in { programs.fish.interactiveShellInit = ''
    source "${atuin_init}" && source "${atuin_comp}"
''; } )

]
