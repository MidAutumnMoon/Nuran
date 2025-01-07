require "nvim-treesitter.configs" .setup {

    -- ensure_installed = {
    --     "vim",
    --     "lua",
    --     "bash",
    --     "fish",
    --     "tcl",
    --     "c",
    --     "rust",
    --     "python",
    --     "ruby",
    --     "nix",
    --     "javascript",
    --     "typescript",
    --     "tsx",
    --     "css",
    --     "html",
    --     "markdown",
    --     "zig",
    --     "perl",
    --     "json",
    --     "yaml",
    --     "toml",
    --     "ninja",
    --     "sql",
    --     "hlsl",
    --     "glsl",
    --     "terraform",
    --     "prolog",
    --     "typst",
    -- },

    highlight = {
        enable = true
    },

--     #incremental_selection = {
--         enable = true,
--         keymaps = {
--             init_selection = "<C-space>",
--             node_incremental = "<C-space>",
--             scope_incremental = true,
--             node_decremental = "<bs>",
--         },
--     },

    indent = {
        enable = true,
        disable = {
            "ruby",
            "nix",
            "rust",
        },
    },

    matchup = {
        enable = true
    },

    endwise = {
        enable = true
    },

}

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
