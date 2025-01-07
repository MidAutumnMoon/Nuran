--
-- Bootstrap Lazy.nvim
--

(function()

    local stdpath = vim.fn.stdpath
    local lazy_path = stdpath( 'data' ) .. "/lazy/lazy.nvim"

    vim.opt.rtp:prepend( lazy_path )

end)()


-- Plugins

local Plugins = {

    --
    -- Editing
    --

    {
        "tpope/vim-repeat",
    },

    {
        "tommcdo/vim-exchange",
        keys = { "cx" },
    },

    {
        "wellle/targets.vim",
    },

    {
        "junegunn/vim-after-object",
        keys = "ca",
        config = function()
            vim.fn["after_object#enable"]( "=", ":", "|", ";", " " )
        end
    },

    {
        "junegunn/vim-easy-align",
        keys = "ga",
        config = function()
            local set = vim.keymap.set
            local keyconf = { remap = true; }
            set( "n", "ga", "<Plug>(EasyAlign)", keyconf )
            set( "x", "ga", "<Plug>(EasyAlign)", keyconf )
        end
    },

    {
        "echasnovski/mini.surround",
        event = { 'CursorMoved', 'CursorHold' },
        keys = { "ys", "cs", "ds" },
        opts = {
            n_lines = 40,
        }
    },

    {
        "echasnovski/mini.move",
        opts = {},
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require "plugin.autopairs"
        end
    },

    {
        "windwp/nvim-ts-autotag",
        after = "nvim-treesitter",
        opts = {},
    },

    -- {
    --     "eraserhd/parinfer-rust",
    --     ft = {
    --         "racket",
    --         "lisp",
    --         "scheme"
    --     },
    --     build = {
    --         "cargo build --release",
    --         "rm -fr target/release/build/",
    --         "rm -fr target/release/deps/",
    --     },
    -- },

    --
    -- Navigating
    --

    {
        "ggandor/leap.nvim",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            require "plugin.leap"
        end
    },

    {
        "kevinhwang91/nvim-fFHighlight",
        keys = { "f", "F" },
        opts = {
            number_hint_threshold = 2,
            prompt_sign_define = { text = "f" },
        }
    },

    {
        "nvim-telescope/telescope.nvim",
        keys = { "<Leader>" },
        cmd = "Telescope",
        config = function()
            require "plugin.telescope"
        end
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        cmd = "Neotree",
        event = { "CursorMoved", "CursorHold" },
        config = function()
            require "plugin.neo-tree"
        end
    },

    {
        "andymass/vim-matchup",
        after = "nvim-treesitter",
    },

    --
    -- QoL
    --

    {
        "tpope/vim-eunuch",
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        event = { 'CursorHold', 'CursorMoved' },
        main = "ibl",
        opts = { },
    },

    {
        "lewis6991/gitsigns.nvim",
        name = "gitsigns",
        config = function()
            require "plugin.gitsigns"
        end
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "Isrothy/lualine-diagnostic-message"
        },
        config = function()
            require "plugin.lualine"
        end
    },

    {
        "nanozuki/tabby.nvim",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function() require "plugin.tabby" end
    },

    {
        "HiPhish/rainbow-delimiters.nvim",
        main = "rainbow-delimiters.setup",
        opts = {},
    },

    --
    -- Cmp & LSP
    --

    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require "plugin.cmp"
        end
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            require "plugin.lspconfig"
        end
    },

    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets"
        },
        config = function()
            local lazy_load = require( "luasnip.loaders.from_vscode" ).lazy_load
            lazy_load { }
            lazy_load {
                paths = "./snippets",
                default_priority = 2000,
            }
        end
    },

    --
    -- Treesitter
    --

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        name = "treesitter",
        config = function()
            require "plugin.treesitter"
        end
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            max_lines = 3,
        },
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
    },

    {
        -- Wait for https://github.com/RRethy/nvim-treesitter-endwise/pull/42 to be merged
        -- "RRethy/nvim-treesitter-endwise",
        "metiulekm/nvim-treesitter-endwise",
        after = "nvim-treesitter",
    },

    --
    -- Languages
    --

    {
        "isobit/vim-caddyfile",
        ft = { "caddyfile" },
    },

    {
        "imsnif/kdl.vim",
        ft = { "kdl" }
    },

    {
        "bellinitte/uxntal.vim"
    },

    --
    -- Colorschemes
    --

    -- {
    --     "folke/tokyonight.nvim",
    --     enabled = false,
    --     config = function() require "plugin.tokyonight" end
    -- },

    -- {
    --     "catppuccin/nvim",
    --     name = "catppuccin",
    --     config = function() require "plugin.catppuccin" end
    -- },

    {
        "rebelot/kanagawa.nvim",
        config = function ()
            require "kanagawa".setup { }
            vim.cmd "colorscheme kanagawa-wave"
        end
    },

    --
    -- Other things
    --

    {
        "nvim-lua/plenary.nvim"
    }

} -- End Plugins

local Config = {

    checker = { enabled = false },

    lockfile = vim.fn.stdpath('state') .. "/lazy-lock.json",

    rtp = { reset = true }

} -- End Config

require "lazy".setup( Plugins, Config )


vim.cmd [[ command! P :Lazy sync ]]
