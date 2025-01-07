local SkippedFiletype = {
    "neo-tree",
}

local function skipping()
    return vim.tbl_contains( SkippedFiletype, vim.bo[0].filetype )
end


local KeyCommands = {
    ["<Tab>"] = "wincmd w",
    ["<S-Tab>"] = "wincmd W",
}

for key, command in pairs( KeyCommands ) do

    vim.keymap.set( "n", key, function()
        vim.cmd( command )
        while skipping() do
            vim.cmd( command )
        end
    end )

end
