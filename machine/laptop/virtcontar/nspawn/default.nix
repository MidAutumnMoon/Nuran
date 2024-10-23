{ lib, ... }:

lib.mkMerge [

{ systemd.nspawn."arch" = {

  enable = true;

  execConfig = {
    Boot = true;
    PrivateUsers = 0;
  };

  filesConfig = {
    TemporaryFileSystem = "/tmp:size=50%";
    Bind = [
      "/dev/dri"
      "/dev/nvidia0"
      "/dev/nvidiactl"
      "/dev/nvidia-uvm"
      "/dev/nvidia-uvm-tools"
      "/dev/nvidia-modeset"
    ];
  };

  networkConfig.Private = false;

}; }

{ systemd.units."systemd-nspawn@arch.service.d/99-override.conf".text = ''
  [Service]
  DeviceAllow = /dev/dri rwm
  DeviceAllow = /dev/nvidia0 rwm
  DeviceAllow = /dev/nvidiactl rwm
  DeviceAllow = /dev/nvidia-uvm rwm
  DeviceAllow = /dev/nvidia-uvm-tools rwm
  DeviceAllow = /dev/nvidia-modeset rwm
''; }

{
  security.polkit.extraConfig =
    builtins.readFile ./policy.js;
}

]
