{ lib, pkgs, ... }:

{

  #
  # 1) Prepare Arch Linux tarball.
  #
  #    - curl https://hub.nspawn.org/storage/archlinux/archlinux/tar/image.tar.zstd
  #    - machinectl import-tar ./image.tar.zstd arch
  #

  systemd.nspawn."arch" = {
      enable = true;
      execConfig =
        { Boot = true;
          PrivateUsers = 0;
        };
      networkConfig.Private = false;
    };

}
