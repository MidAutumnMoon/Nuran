{ modulesPath, ... }:

{

    imports = [
        ( modulesPath + "/profiles/qemu-guest.nix" )
        # ./environment.nix
        # ./service
    ];

    networking = {
        hostName = "joar";
        useDHCP = true;
    };

    boot.loader.grub = {
        enable = true;
        device = "/dev/sda";
    };

    boot.initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
    ];

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/f090afd4-e5ae-4c20-8f9d-ccefd1359013";
        fsType = "btrfs";
        options = [ "defaults" "compress-force=zstd:9" ];
    };

    swapDevices = [
        { device = "/dev/disk/by-uuid/0b42456a-ae3b-4903-bb8c-206948a27cbe"; }
    ];

}
