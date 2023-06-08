{ lib, pkgs, config, ... }:

{

    boot.kernelPackages =
        lib.mkForce pkgs.linuxPackages_teapot;

    boot.initrd = {
        kernelModules = [
            "nvme"
        ];
        availableKernelModules = [
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
        "configs"
    ];

    boot.kernelParams = [
        "preempt=full"
        "init_on_alloc=1"
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

}
