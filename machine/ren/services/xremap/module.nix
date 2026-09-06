{
    services.xremap = {
        enable = true;
        withNiri = true;
        serviceMode = "user";
        userName = "teapot";
    };

    services.xremap.config = {
        keymap = [
            {
                name = "Generic Ctrl-w Kill Words";
                application.only = [
                    "org.telegram.desktop"
                    "CherryStudio"
                    "zcode"
                ];
                remap = {
                    "C-w" = "C-Backspace";
                };
            }
            # C-w deletes words now, so A-w restores the original shortcut.
            {
                name = "Firefox Specific Ctrl-W Tweaks";
                application.only = [ "firefox" ];
                remap = {
                    "C-w" = "C-Backspace";
                    "A-w" = "C-w";
                };
            }
        ];
    };
}
