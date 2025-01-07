{ lib, config, pkgs, ... }:

let

    inherit ( config.xdg )
        configHome
    ;

in {

    imports = [
        ./fish.nix
    ]
    ++ ( lib.listAllModules ../../../dotfiles )
    ;

    home.packages = with pkgs; [
        sops
        rust-analyzer_teapot
        ruby_teapot.with_preferred_gems
        ruby_teapot.rubocop

        nixd
        colmena

        wsl-open

        inori
    ];

    sops.age.keyFile = "${configHome}/sops/age/keys.txt";

}
