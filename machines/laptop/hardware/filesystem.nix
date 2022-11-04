{ config, lib, ... }:

{

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=755" ];
    };

  fileSystems."/nix" =
    { device = "aquae/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "aquae/local/log";
      fsType = "zfs";
    };

  fileSystems."/var/lib" =
    { device = "aquae/local/lib";
      fsType = "zfs";
    };

  fileSystems."/var/tmp" =
    { device = "aquae/local/tmp";
      fsType = "zfs";
    };

  fileSystems."/var/cache" =
    { device = "aquae/local/cache";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "aquae/safe/home";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    { device = "aquae/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1BD4-6174";
      fsType = "vfat";
    };

  swapDevices =
    [ {
      device = "/dev/disk/by-uuid/932e25e5-a659-4e66-bebe-fc9bda581083";
      discardPolicy = "both";
    } ];

}
