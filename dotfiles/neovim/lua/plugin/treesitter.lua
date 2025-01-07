require "nvim-treesitter.configs" .setup {

    highlight = {
        enable = true,
        disable = {
            -- Broken
            "ssh_config",
        },
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
