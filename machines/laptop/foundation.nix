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
        "configs"
    ];

    boot.kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=lz4"
        "zswap.max_pool_percent=20"
        "nohz_full=2-15"
        "rcu_nocbs=2-15"
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
        cryptoModules = [
            "aes"
            "aes_generic"
            "xts"
            "sha512"
        ];
        devices."lyfua" = {
            device = "/dev/disk/by-uuid/fcdf1ea7-8aa1-4dd6-9271-c010612fca41";
            bypassWorkqueues = true;
            allowDiscards = true;
        };
    };


}

# Filesystem

( let

    device = "/dev/mapper/lyfua";

    baseOption =
        [ "defaults" "compress-force=zstd:2" "noatime" "discard=async" ];

    subvol =
        name: baseOption ++ [ "subvol=${name}" ];

in {

    fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "defaults" "size=16G" "mode=755" ];
    };

    fileSystems."/home" = {
        inherit device;
        fsType = "btrfs";
        options = subvol "home";
    };

    fileSystems."/nix" = {
        inherit device;
        fsType = "btrfs";
        options = subvol "nix";
    };

    fileSystems."/persist" = {
        inherit device;
        fsType = "btrfs";
        neededForBoot = true;
        options = subvol "persist";
    };

    fileSystems."/var" = {
        inherit device;
        fsType = "btrfs";
        options = subvol "var";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/FD5E-3536";
        fsType = "vfat";
        options = [ "defaults" ];
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/a70dc6c5-5746-4587-bb58-b809af148645"; }
    ];

} )

]
