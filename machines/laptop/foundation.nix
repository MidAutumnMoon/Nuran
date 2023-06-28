{ lib, pkgs, ... }:

lib.mkMerge [

# Kernel & Bootloader

{

    boot.kernelPackages =
        lib.mkForce pkgs.linuxPackages_teapot;

    boot.initrd = {
        kernelModules = [
            "nvme"
            "hid_generic"
            "usbhid"
            "xhci_pci"
            "xhci_hcd"
        ];
        includeDefaultModules = false;
    };

    boot.blacklistedKernelModules = [
        "nouveau"
        "i2c_nvidia_gpu"
    ];

    boot.kernelModules = [
        "amdgpu"
        "configs"
    ];

    boot.kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=lz4"
        "zswap.max_pool_percent=20"
    ];

    hardware.cpu.amd.updateMicrocode = true;

    hardware.enableRedistributableFirmware = true;


    # Bootloader

    boot.initrd.systemd.enable = true;

    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    boot.initrd.luks = {
        devices."reuuko" = {
            device = "/dev/disk/by-uuid/73533ebf-8f78-4725-95b5-d8627670380c";
            bypassWorkqueues = true;
            allowDiscards = true;
        };
    };


}

# Filesystem

( {

    services.fstrim.enable = true;

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/c6f0db12-df94-466c-b6f6-a5629cbec666";
        fsType = "xfs";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/BF50-E761";
        fsType = "vfat";
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/e77a4a82-7a65-4d97-81d2-599b2be8778e"; }
    ];

} )

{
    powerManagement.cpuFreqGovernor = "ondemand";
}

]
