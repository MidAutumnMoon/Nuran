{ lib, config, ... }:

lib.condMod (config.services.gpg-agent.enable) {

  services.gpg-agent = {
      defaultCacheTtl = 1200;
      pinentryFlavor = "qt";

      enableSshSupport = true;
      sshKeys =
        [ "10213195CAE6C6E9E2A3FB0E629B46EA61AC32BB" ];
    };

}
