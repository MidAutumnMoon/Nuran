{ config, ... }:

{

  imports =
    [
      ./environment.nix
      ./programs.nix
      ./services.nix
    ];

}

