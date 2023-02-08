{ lib, pkgs, ... }:

{

  boot.kernelPackages =
    lib.mkForce pkgs.linuxPackages-teapot;

  boot.initrd.includeDefaultModules = false;

  boot.initrd.availableKernelModules = [
      "hid_generic"
      "usbhid"
      "xhci_pci"
      "xhci_hcd"
    ];

  boot.kernelModules = [
      "amdgpu"
    ];

  boot.blacklistedKernelModules = [
      "nouveau"
      "i2c_nvidia_gpu"
    ];

  boot.kernelParams = [ "preempt=full" ];

  hardware.cpu.amd.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;


  # Bootloader

  boot.initrd.systemd.enable = true;

  boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

}
