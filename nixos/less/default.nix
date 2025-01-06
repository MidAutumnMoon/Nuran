{ config, ... }:

{
    programs.less.envVariables = {
        LESS = builtins.concatStringsSep " " [
            "--RAW-CONTROL-CHARS"
            "--mouse"
            "--wheel-lines=5"
            "--quit-if-one-screen"
            "--ignore-case"
            "--LONG-PROMPT"
            "--HILITE-UNREAD"
            "--tabs=4"
            "--window=-4"
            "--use-color"
        ];
    };

    environment.variables."LESS" =
        config.programs.less.envVariables.LESS;

}
