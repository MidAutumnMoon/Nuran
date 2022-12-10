{ lib, config, flake, pkgs, ... }:

let

  homeManagersLib =
    import "${flake.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;

  libPlusHomeManagersLib =
    lib // homeManagersLib;

in

{

  home-manager = {

      useGlobalPkgs = true;

      useUserPackages = true;

      # Why does this work?
      # - home-manager/0232fe1b75e6d7864fd82b5c72f6646f87838fc3/nixos/default.nix#L17
      extraSpecialArgs = {
          lib = libPlusHomeManagersLib;
          inherit flake;
        };

      sharedModules =
        lib.listAllModules config.nudata.paths.homeModules;

    };

}

