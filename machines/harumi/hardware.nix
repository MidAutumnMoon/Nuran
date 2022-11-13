{ config, lib, pkgs, ... }:

{

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  boot.loader.grub.mirroredBoots = [
    { devices = [ "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_57M8K00TF7GB" ];
      path = "/boot"; }
    { devices = [ "/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_57M7K024F7GB" ];
      path = "/boot2";
    } ];

  boot.initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
    ];

  boot.blacklistedKernelModules = [
      "i915"
      "snd_hda_intel"
    ];

  boot.kernelParams = [
      "preempt=none"
    ];

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.intel.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = "performance";

  services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd*", ATTR{queue/scheduler}="none"
    '';

}
