{

  networking.hostName = "lyfua";

  networking.networkmanager.enable = true;

  systemd.network.wait-online.extraArgs = [
      "--interface=wlp2s0:routable"
    ];

}
