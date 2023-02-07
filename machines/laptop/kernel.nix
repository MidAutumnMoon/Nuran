{ lib, pkgs, ... }:

{

  boot.kernelModules = [ "amdgpu" ];

  boot.blacklistedKernelModules = [
      "nouveau"
      "i2c_nvidia_gpu"
    ];

  boot.kernelParams = [ "preempt=full" ];

  hardware.cpu.amd.updateMicrocode = true;

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages =
    lib.mkForce pkgs.linuxPackages-teapot;


  # Bootloader

  boot.initrd.systemd.enable = true;

  boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

}
