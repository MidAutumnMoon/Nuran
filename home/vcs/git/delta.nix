{ lib, pkgs, ... }:

let

  deltaWithConfig = pkgs.writeShellScript "delta-w-config" ''
    export LESS="LR --wheel-lines=3"
    exec "${lib.getExe pkgs.delta}"
    '';

in

{ xdg.configFile."git/config".text = ''

  # delta

  [core]
    pager = "${deltaWithConfig}"

  [delta]
    navigate = true
    hyperlinks = true
    line-numbers = true;
    side-by-side = true;

''; }
