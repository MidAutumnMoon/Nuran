local wezterm = require 'wezterm'

local config = {}


--
-- Fonts
--

config.font = wezterm.font_with_fallback {
    {
        family = "Iosevka Teapot",
        weight = "Medium",
        stretch = "Expanded",
    },
    {
        family = "Hack Nerd Font",
        weight = "Regular",
    },
    {
        family = "Noto Sans CJK SC",
        weight = "Medium",
    },
    {
        family = "Noto Sans CJK TC",
        weight = "Medium",
    },
    {
        family = "Noto Sans CJK JP",
        weight = "Medium",
    },
}

config.font_size = 16.4
config.line_height = 1.12

config.use_cap_height_to_scale_fallback_fonts = true


--
-- Appearance
--

config.initial_cols = 186
config.initial_rows = 42

config.background = {
    {
        source = { Color = "black" },
        width = "100%",
        height = "100%",
        opacity = 0.72,
    }
}

wezterm.on( "window-focus-changed", function( window, pane )
    os.execute( '@blurScriptAsync@' )
end )

config.hide_tab_bar_if_only_one_tab = true
-- config.use_fancy_tab_bar = false

config.window_padding = {
    right = 0,
    left = 0,
    top = 0,
    bottom = 0,
}

config.window_decorations = "NONE"

config.window_frame = {
    font = wezterm.font { family = 'Hack', weight = 'Bold' },
    font_size = config.font_size - 1,
}


--
-- Misc
--

config.check_for_updates = false
config.enable_wayland = false
config.mouse_wheel_scrolls_tabs = true


return config
