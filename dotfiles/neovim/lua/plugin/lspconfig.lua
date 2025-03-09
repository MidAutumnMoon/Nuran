local lspconfig = require "lspconfig"

local servers = {
    nixd = {
        cmd = { "nixd", "--semantic-tokens=false" },
    },
    rust_analyzer = {},
    rubocop = { single_file_support = true, },
    -- denols = {},
}

local lsp_keymaps = {
    ["K"] = vim.lsp.buf.hover,
    ["]d"] = vim.diagnostic.goto_next,
    ["[d"] = vim.diagnostic.goto_prev,
    ["gd"] = vim.lsp.buf.definition,
    ["gi"] = vim.lsp.buf.implementation,
    ["<F2>"] = vim.lsp.buf.rename,
}

for server, config in pairs( servers ) do
    -- set keymaps
    config.on_attach = function ( client, bufnr )
        for key, action in pairs( lsp_keymaps ) do
            vim.keymap.set( "n", key, action, { silent = true, buffer = bufnr } )
        end
        if server == "nixd" then
            client.server_capabilities.completionProvider = false
        end
    end

    -- extend lsp capabilities
    local has_blink, blink = pcall( require, "blink-cmp" )
    local has_cmp, cmp_lsp = pcall( require, "cmp_nvim_lsp" )

    assert(
        not (has_blink and has_cmp),
        "Don't use cmp and blink at the same time!"
    )

    if has_blink then
        config.capabilities = blink.get_lsp_capabilities( config.capabilities )
        config.capabilities
            .textDocument
            .completion
            .completionItem
            .snippetSupport = false
    end

    if has_cmp then
        config.capabilities = cmp_lsp.default_capabilities()
        config.capabilities
            .textDocument
            .completion
            .completionItem
            .snippetSupport = false
    end

    lspconfig[server].setup( config )
end

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
