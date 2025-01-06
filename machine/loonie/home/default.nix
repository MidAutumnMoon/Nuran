{ config, pkgs, ... }:

let

    inherit ( config.xdg )
        configHome
    ;

in {

    imports = [
        ./git
        ./ssh
        ./dotfiles

        ./fish.nix
    ];

    home.packages = with pkgs; [
        sops
        rust-analyzer_teapot
        ruby_teapot.with_preferred_gems
        ruby_teapot.rubocop
        nixd
        colmena
        gcc
        wsl-open
    ];

    sops.age.keyFile = "${configHome}/sops/age/keys.txt";

}
