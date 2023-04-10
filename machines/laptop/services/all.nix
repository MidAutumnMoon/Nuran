{ lib, config, ... }:

lib.mkMerge [

{ services = {

  flatpak.enable = true;

  openssh.enable = true;

  openssh.openFirewall = false;

  power-profiles-daemon.enable = true;

  dbus.implementation = "broker";

}; }

{
  # Not enough memory :(
  nix.settings.cores = lib.mkForce 8;

  nix.extraOptions = ''
    !include ${config.sops.secrets."nix_token_config".path}
  '';
}

]
