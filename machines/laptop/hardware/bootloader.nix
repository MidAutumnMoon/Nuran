{

  boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

  boot.initrd = {
      availableKernelModules = [ "nvme" ];
    };

  boot.initrd.systemd.enable = true;

}
