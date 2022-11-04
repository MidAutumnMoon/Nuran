{

  services.xserver.libinput =
    { enable = true;
      touchpad =
        { scrollMethod = "twofinger";
          naturalScrolling = true;
          clickMethod = "clickfinger";
          accelProfile = "flat";
          accelSpeed = "1";
          additionalOptions = ''
              Option "ScrollPixelDistance" "2"
            '';
        };
    };

}
