let

  defaultOptions =
    [ "defaults" ];

  securityOptions =
    [ "nodev" "nosuid" ];

in

{

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=755" ];
    };

  fileSystems."/nix" =
    { device = "harumi/local/nix";
      fsType = "zfs";
      options = defaultOptions;
    };

  fileSystems."/var" =
    { device = "harumi/local/var";
      fsType = "zfs";
      options = defaultOptions;
    };

  fileSystems."/root" =
    { device = "harumi/local/root";
      fsType = "zfs";
      options = defaultOptions;
    };

  fileSystems."/persist" =
    { device = "harumi/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
      options =
        defaultOptions ++ securityOptions;
    };


  # Data

  systemd.tmpfiles.rules =
    [ "z /data 0755 root root" ];

  fileSystems."/data/erohon" =
    { device = "harumi/data/erohon";
      fsType = "zfs";
      options =
        defaultOptions ++ securityOptions;
    };

  fileSystems."/data/flaimgo" =
    { device = "harumi/data/picture";
      fsType = "zfs";
      options =
        [ "nofail" ] ++ defaultOptions ++ securityOptions;
    };

  fileSystems."/var/lib/postgresql" =
    { device = "harumi/data/postgresql";
      fsType = "zfs";
      options =
        defaultOptions ++ securityOptions;
    };

  fileSystems."/data/hentai-home" =
    { device = "harumi/data/hentai";
      fsType = "zfs";
      options =
        defaultOptions ++ securityOptions;
    };


  # Boots

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0BB3-0FA6";
      fsType = "vfat";
      options =
        defaultOptions ++ securityOptions;
    };

  fileSystems."/boot2" =
    { device = "/dev/disk/by-uuid/0A63-CEAF";
      fsType = "vfat";
      options =
        defaultOptions ++ securityOptions;
    };

}
