{

  services.journald.extraConfig = ''
    Storage = volatile
    SystemMaxUse = 1G
    RuntimeMaxUse = 1G
    '';

}
