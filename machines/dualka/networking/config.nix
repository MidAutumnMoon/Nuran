{ networking = {

  hostName = "dualka";
  useDHCP = false;

  interfaces."ens18".ipv4.addresses = [ {
    address = "134.195.101.168";
    prefixLength = 24;
  } ];

  interfaces."ens18".ipv6.addresses = [ {
    address = "2602:feda:30:af86::d4";
    prefixLength = 64;
  } ];

  defaultGateway = "134.195.101.175";

  defaultGateway6.address = "2602:feda:30:af86::1";

}; }
