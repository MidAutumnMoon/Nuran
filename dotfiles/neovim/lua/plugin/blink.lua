local blink = require "blink-cmp"
local devicons = require "nvim-web-devicons"
local lspkind = require "lspkind"

local option = {}

option.completion = {
    keyword = { range = "full" },
    accept = {},
    trigger = {
        show_in_snippet = false,
    },
    list = {
        selection = { auto_insert = false },
    },
}

option.completion.menu = {
    border = "rounded",
    scrollbar = false,
    draw = {
        columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", gap = 1, },
        },
    },
}

option.completion.menu.draw.components = {}

option.completion.menu.draw.components.kind_icon = {
    ellipsis = false,
    text = function ( ctx )
        local icon = ctx.kind_icon
        if vim.tbl_contains( { "Path" }, ctx.source_name ) then
            local dev_icon, _ = devicons.get_icon( ctx.label )
            if dev_icon then icon = dev_icon end
        else
            icon = lspkind.symbolic( ctx.kind, { mode = "symbol", } )
        end
        return icon .. ctx.icon_gap
    end
}

option.completion.documentation = {
    auto_show = true,
    auto_show_delay_ms = 0,
    window = { border = "rounded" },
}

option.keymap = {
    preset = "super-tab",
    -- To exit insert mode directly,
    -- otherwise <Esc> has to be pressed twice :/
    ["<Esc>"] = { "fallback" },
}

option.cmdline = {
    completion = { menu = { auto_show = true } },
}

option.snippets = {
    preset = "luasnip",
}

blink.setup( option )
