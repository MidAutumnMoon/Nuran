local cmp = require "cmp"
local cmp_buffer = require "cmp_buffer"
local luasnip = require "luasnip"
local lspkind = require "lspkind"

local sources = {}

sources.buffer = {
    name = "buffer",
    option = {
        -- only visible buffers
        get_bufnrs = function()
            local bufs = {}
            for _, win in ipairs( vim.api.nvim_list_wins() ) do
                bufs[vim.api.nvim_win_get_buf(win)] = true
            end
            return vim.tbl_keys(bufs)
        end,
        max_indexed_line_length = 200,
        keyword_pattern = [[\k\+]],
    }
}

cmp.setup {

    sources = cmp.config.sources(
        {
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
            sources.buffer,
            { name = "async_path" },
        }
    ),

    mapping = {
        ['<CR>'] = cmp.mapping( function(fallback)
            if cmp.visible() then
                local selected = cmp.get_selected_entry()
                if selected == nil then
                    return fallback()
                elseif selected.name == "luasnip" and luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm { select = true }
                end
            else
                return fallback()
            end
        end ),

        ["<Tab>"] = cmp.mapping( function( fallback )
            if luasnip.locally_jumpable( 1 ) then
                luasnip.jump( 1 )
            elseif cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" } ),

        ["<S-Tab>"] = cmp.mapping( function( fallback )
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable( -1 ) then
                luasnip.jump( -1 )
            else
                fallback()
            end
        end, { "i", "s" } ),

        ["<C-e>"] = cmp.mapping( function( fallback )
            if cmp.visible() then
                cmp.mapping.abort()
            else
                fallback()
            end
        end ),
    },

    preselect = cmp.PreselectMode.None,

    matching = {
        disallow_fullfuzzy_matching = true,
    },

    formatting = {
        format = lspkind.cmp_format {
            mode = "symbol_text",
            show_labelDetails = true,
        },
        fields = { "abbr", "kind" },
    },

    snippet = {
        expand = function(args)
            luasnip.lsp_expand( args.body )
        end,
    },

    window = {
        completion = cmp.config.window.bordered { border = "rounded" },
        documentation = cmp.config.window.bordered { border = "rounded" },
    },

    experimental = {
        ghost_text = false,
    },
}


cmp.setup.cmdline( ":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "cmdline" },
        { name = "path" },
    }
} )

cmp.setup.cmdline( "/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { sources.buffer }
} )
