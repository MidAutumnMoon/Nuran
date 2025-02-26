local lspconfig = require "lspconfig"
local lsp_utils = require "plugin.lspconfig.utils"

local lsp_setup = lsp_utils.lsp_setup


--
-- Setups
--

lsp_setup( lspconfig.nixd, {
    cmd = { "nixd", "--semantic-tokens=false" }
} )

lsp_setup( lspconfig.rust_analyzer, { } )

lsp_setup( lspconfig.rubocop, {
    single_file_support = true
} )

-- lsp_setup( lspconfig.denols, {
--     single_file_support = true
-- } )

-- lsp_setup( lspconfig.lua_ls, {
--     settings = { Lua = {
--         runtime = {
--             version = "LuaJIT",
--             pathStrict = false,
--             path = { "?.lua", "?/init.lua", "lua/?.lua", "lua/?/init.lua" },
--         },
--         workspace = {
--             checkThirdParty = false,
--             maxPreload = 10 * 1000 * 1000,
--             library = vim.api.nvim_get_runtime_file( "", true )
--         }
--     } }
-- } )

-- lsp_setup( lspconfig.tinymist, {
--     single_file_support = true,
-- } )

vim.diagnostic.config {
    update_in_insert = false,
    underline = true,
    virtual_text = false,
    severity_sort = true,
    float = { border = "rounded" }
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" }
)
