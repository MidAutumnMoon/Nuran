{ pkgs, ... }:

{

  services.udev.packages =
    [ pkgs.k380-fn-keys-swap ];

}
