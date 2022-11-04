{

  imports =
    [ ./fixup/kill-logrotate.nix ];


  services.vnstat.enable =
    true;

  services.openssh.enable =
    true;

}
