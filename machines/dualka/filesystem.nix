{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5ad52988-ac8d-4db3-b914-e0e99734394d";
      fsType = "xfs";
      options = [ "defaults" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/5ec0674e-2bc8-4d7a-95ce-139549b63369"; } ];

}
