{ pkgs, ...  }:

{

  # Bluetooth

  hardware.bluetooth.enable = true;


  # Misc udev

  services.udev.packages =
    [ pkgs.k380-fn-keys-swap ];

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    '';


  # Sound

  services.pipewire.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
    };

  services.pipewire.config.pipewire = {
      "context.properties" =
        { "log.level" = 3;
          "link.max-buffers" = 64;
        };
    };


  # Graphic

  services.xserver = {
      enable = true;
      dpi    = 120;
      videoDrivers = [ "amdgpu" "nvidia" ];
    };

  hardware.opengl = {
      enable     = true;
      driSupport = true;
    };

  hardware.nvidia = {
      nvidiaSettings = false;
      modesetting.enable = true;
    };

  hardware.nvidia.powerManagement = {
      enable = true;
      finegrained = true;
    };

  hardware.nvidia.prime = {
      offload.enable = true;
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };

  hardware.video.hidpi.enable = true;


  # Touchpad

  services.xserver.libinput.enable = true;

  services.xserver.libinput.touchpad = {
      scrollMethod = "twofinger";
      naturalScrolling = true;
      clickMethod = "clickfinger";
      accelProfile = "flat";
      accelSpeed = "1";
    };

  services.xserver.libinput.touchpad.additionalOptions = ''
    Option "ScrollPixelDistance" "2"
    '';

}
