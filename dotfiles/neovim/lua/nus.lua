local M = {}


--- Set multiple keymaps at once with a set of common keymap modes
---
--- Usage examples:
---
---     BatchSetKeymaps { "n" } { "gc" = ":cmd" }
---     BatchSetKeymaps( { "n" }, { silent = true } ) { "gc" = ":cmd" }
---
--- @param mode string[] Array of modes of what vim.keymap.set() accepts
--- @param options table? Options which vim.keymap.set() accepts
--- @return fun( keymaps: table<string, unknown> ): nil
M.BatchSetKeymaps = function( mode, options )
    --- @param keymaps table<string, unknown> Keymaps to their actions
    local function setter( keymaps )
        for key, action in pairs( keymaps ) do
            vim.keymap.set( mode, key, action, options or {} )
        end
    end
    return setter
end


--- A common set of filetypes to ignore
M.ExcludedFiletypes = {
    -- No files
    "",
    "nofile",
    -- Vim internal
    "help",
    -- Plugins
    "TelescopePrompt"
}


return M
