{

  services.xserver =
    { enable = true;
      dpi    = 120;
      videoDrivers = [ "amdgpu" "nvidia" ];
    };

  hardware.opengl =
    { enable     = true;
      driSupport = true;
    };

  hardware.nvidia =
    { nvidiaSettings =
        false;
      modesetting.enable =
        true;
      powerManagement =
        { enable = true;
          finegrained = true;
        };

      prime =
        { offload.enable = true;
          amdgpuBusId = "PCI:4:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
    };

  hardware.video.hidpi.enable =
    true;

}
