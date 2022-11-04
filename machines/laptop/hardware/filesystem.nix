{ config, lib, pkgs, ... }:

let

  baseOption =
    [ "compress-force=zstd" "noatime" ];

in

{

  boot.initrd.luks.devices."lyfua" = {
      device =
        "/dev/disk/by-uuid/fcdf1ea7-8aa1-4dd6-9271-c010612fca41";
    };


  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=755" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/lyfua";
      fsType = "btrfs";
      options = [ "subvol=home" ] ++ baseOption;
    };

  # fileSystems."/etc" =
  #   { device = "/dev/mapper/lyfua";
  #     fsType = "btrfs";
  #     options = [ "subvol=etc" ] ++ baseOption;
  #   };

  fileSystems."/nix" =
    { device = "/dev/mapper/lyfua";
      fsType = "btrfs";
      options = [ "subvol=nix" ] ++ baseOption;
    };

  fileSystems."/persist" =
    { device = "/dev/mapper/lyfua";
      fsType = "btrfs";
      options = [ "subvol=persist" ] ++ baseOption;
      neededForBoot = true;
    };

  fileSystems."/root" =
    { device = "/dev/mapper/lyfua";
      fsType = "btrfs";
      options = [ "subvol=root" ] ++ baseOption;
    };

  fileSystems."/var" =
    { device = "/dev/mapper/lyfua";
      fsType = "btrfs";
      options = [ "subvol=var" ] ++ baseOption;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/FD5E-3536";
      fsType = "vfat";
    };


  swapDevices =
    [ { device = "/dev/disk/by-uuid/a70dc6c5-5746-4587-bb58-b809af148645"; } ];

}
