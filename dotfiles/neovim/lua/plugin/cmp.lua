local cmp = require "cmp"
local cmp_buffer = require "cmp_buffer"
local luasnip = require "luasnip"


local sources = {}

sources.buffer = {
    name = "buffer",
    option = {
        -- Get words from all buffers
        get_bufnrs = vim.api.nvim_list_bufs,
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
            { name = "path" },
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

    snippet = {
        expand = function(args)
            luasnip.lsp_expand( args.body )
        end,
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
