{ lib, pkgs, ... }:

{

  boot.kernelModules = [
      "fuse"
      "amdgpu"
    ];

  boot.blacklistedKernelModules = [
      "nouveau"
      "i2c_nvidia_gpu"
    ];

  boot.kernelParams = [
      "preempt=full"
    ];

  hardware.cpu.amd.updateMicrocode = true;

  boot.kernelPackages =
    lib.mkForce pkgs.linuxPackages-teapot;

  boot.kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr2";
      "vm.swappiness" = 1;
    };

  hardware.enableRedistributableFirmware = true;

}
