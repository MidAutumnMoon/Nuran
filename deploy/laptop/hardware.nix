{ pkgs, ...  }:

{

    # Bluetooth

    hardware.bluetooth.enable = true;


    # Misc udev

    services.udev.extraRules = let
        batThreshold = "85";
        batPath = "/sys/class/power_supply/BAT?/charge_control_end_threshold";
        batRun = "${pkgs.runtimeShell} -c 'echo ${batThreshold} > ${batPath}'";
    in ''
        ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
        ACTION=="add", KERNEL=="asus-nb-wmi", RUN+="${batRun}"
    '';


    # Sound

    services.pipewire.enable = true;

    security.rtkit.enable = true;

    services.pipewire = {
        alsa.enable       = true;
        alsa.support32Bit = true;
        pulse.enable      = true;
    };


    # Graphic

    services.xserver = {
        enable = false;
        dpi    = 120;
        videoDrivers = [ "modesetting" "nvidia" ];
    };

    hardware.opengl = {
        enable     = true;
        driSupport = true;
    };

    hardware.nvidia = {
        nvidiaSettings = false;
        modesetting.enable = true;
        open = true;
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


    # Steam

    hardware.steam-hardware.enable = true;

    hardware.uinput.enable = true;

    users.users."teapot".extraGroups = [ "uinput" ];

}
