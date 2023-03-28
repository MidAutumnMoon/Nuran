{ lib, ... }:

{

  services.flatpak.enable = true;

  # Not enough memory :(
  nix.settings.cores = lib.mkForce 8;

  services.openssh.enable = true;

  services.openssh.openFirewall = false;

  services.power-profiles-daemon.enable = true;

  services.dbus.implementation = "broker";

}
