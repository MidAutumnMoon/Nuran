{

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=755" ];
    };

  fileSystems."/nix" =
    { device = "harumi/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "harumi/local/var";
      fsType = "zfs";
    };

  fileSystems."/root" =
    { device = "harumi/local/root";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    { device = "harumi/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };


  # Data

  systemd.tmpfiles.rules =
    [ "z /data 0755 root root" ];

  fileSystems."/data/erohon" =
    { device = "harumi/data/erohon";
      fsType = "zfs";
    };

  fileSystems."/data/flaimgo" =
    { device = "harumi/data/picture";
      fsType = "zfs";
      options = [ "defaults" "nofail" ];
    };

  fileSystems."/var/lib/postgresql" =
    { device = "harumi/data/postgresql";
      fsType = "zfs";
    };

  fileSystems."/data/hentai-home" =
    { device = "harumi/data/hentai";
      fsType = "zfs";
    };


  # Boots

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0BB3-0FA6";
      fsType = "vfat";
    };

  fileSystems."/boot2" =
    { device = "/dev/disk/by-uuid/0A63-CEAF";
      fsType = "vfat";
    };

}
