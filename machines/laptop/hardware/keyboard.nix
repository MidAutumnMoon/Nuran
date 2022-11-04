{ pkgs, ... }:

{

  services.udev.packages = with pkgs;
    [ k380-fn-keys-swap-udev ];

}
