{ lib, ... }:

{

  networking.hostName = "harumi";
  networking.hostId = "2bcf90c8";

  networking.useDHCP = false;

  networking.interfaces."enp0s31f6".ipv4.addresses = lib.toList
    { address = "138.201.132.96";
      prefixLength = 26;
    };

  networking.interfaces."enp0s31f6".ipv6.addresses = lib.toList
    { address = "2a01:4f8:172:2f99::1";
      prefixLength = 64;
    };

  networking.defaultGateway =
    "138.201.132.65";

  networking.defaultGateway6 =
    { address = "fe80::1";
      interface = "enp0s31f6";
    };

}
