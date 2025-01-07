local M = {}

local function SetKeymap( buffer )
    local keymaps = {
        ["gd"] = vim.lsp.buf.definition,
        ["gi"] = vim.lsp.buf.implementation,
        ["gD"] = vim.lsp.buf.declaration,
        ["gr"] = vim.lsp.buf.references,
        ["<F2>"] = vim.lsp.buf.rename,
        ["K"] = vim.lsp.buf.hover,
        ["]d"] = vim.diagnostic.goto_next,
        ["[d"] = vim.diagnostic.goto_prev,
    }
    for key, map in pairs( keymaps ) do
        vim.keymap.set( "n", key, map, {
            silent = true,
            buffer = buffer,
        } )
    end
end

-- local function float_diagnostic( bufnr )
--   vim.api.nvim_create_autocmd( "CursorHold", {
--     buffer = bufnr,
--     callback = function( info )
--       vim.diagnostic.open_float {
--         focus = false,
--         focusable = false,
--       }
--     end
--   } )
-- end

M.lsp_setup = function( lsp, overrides )
    local cmp_nvim_lsp = require "cmp_nvim_lsp"

    local default_caps = cmp_nvim_lsp.default_capabilities()
    default_caps.textDocument.completion.completionItem.snippetSupport = false

    local defaults = {
        capabilities = default_caps,
        on_attach = function( client, bufnr )
            SetKeymap( bufnr )
            -- float_diagnostic( bufnr )
            -- vim.lsp.inlay_hint.enable( true, { bufnr = bufnr } )
        end
    }
    lsp.setup(
        vim.tbl_deep_extend( "force", defaults, overrides )
    )
end


return M
