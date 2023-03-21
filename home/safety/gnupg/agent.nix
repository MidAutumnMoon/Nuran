{ lib, config, ... }:

lib.condMod (config.programs.gpg.enable) {

  services.gpg-agent.enable = true;

  services.gpg-agent = {
      maxCacheTtl = 34560000;
      maxCacheTtlSsh = 34560000;
      defaultCacheTtl = 34560000;
      defaultCacheTtlSsh = 34560000;
      pinentryFlavor = "qt";

      enableSshSupport = true;
      sshKeys =
        [ "10213195CAE6C6E9E2A3FB0E629B46EA61AC32BB" ];
    };

}
