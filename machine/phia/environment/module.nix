{ pkgs, ... }:

let

    maintenance = pkgs.tsuki.maintenance;

in

{

    environment.systemPackages = [
        maintenance
    ];

    passthru = {
        inherit maintenance;
    };

}
