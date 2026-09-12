{ pkgs, ... }:

let

    phia_toolbox = pkgs.tsuki.phia_toolbox;

in

{

    environment.systemPackages = [ phia_toolbox ];

}
