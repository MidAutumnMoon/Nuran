{

  security.rtkit.enable =
    true;

  services.pipewire.enable =
    true;

  services.pipewire =
    { alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  services.pipewire.config.pipewire =
    { "context.properties" =
        { "log.level" = 3;
          "link.max-buffers" = 64;
        };
    };

}
