{ lib, pkgs, ... }:

let

  deltaExe = lib.getExe pkgs.delta;

  deltaWithConf =
    "LESS='LR --wheel-lines=3' ${deltaExe}";

in

{

  programs.git.iniContent = {

      core.pager =
        lib.mkForce deltaWithConf;

      merge =
        { conflictstyle = "diff3"; };

      delta =
        { line-numbers = true;
          side-by-side = true;
        };

    };

}
