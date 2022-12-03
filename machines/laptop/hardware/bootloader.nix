{

  boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

  boot.initrd = {
      availableKernelModules =
        [ "xhci_pci" "nvme" "ahci" "usbhid" "sd_mod" "amdgpu" ];
    };

  boot.initrd.systemd.enable = true;

}
