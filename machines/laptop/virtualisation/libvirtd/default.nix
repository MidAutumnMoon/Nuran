{ config, pkgs, ... }:

{

  virtualisation.libvirtd =
    { enable = true;
      onBoot = "ignore";
    };

  virtualisation.libvirtd.qemu =
    { package = pkgs.qemu_kvm;
      runAsRoot = false;
    };

  boot.kernelModules =
    [ "kvm-amd" ];

  users.users."teapot".extraGroups =
    [ "qemu-libvirtd" "libvirtd" ];

}
