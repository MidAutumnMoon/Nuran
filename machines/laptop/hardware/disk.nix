{
  services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    '';
}
