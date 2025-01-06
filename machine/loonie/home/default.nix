{ config, pkgs, ... }:

let

    inherit ( config.xdg )
        configHome
    ;

in {

    imports = [
        ./git
        ./ssh
    ];

    home.packages = with pkgs; [
        sops
    ];

    sops.age.keyFile = "${configHome}/sops/age/keys.txt";

}
