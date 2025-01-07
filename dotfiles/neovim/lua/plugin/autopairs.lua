local Rule = require "nvim-autopairs.rule"

local autopairs = require "nvim-autopairs"

local setup = autopairs.setup
local add_rules = autopairs.add_rules
local get_rule = autopairs.get_rule


setup {
    check_ts = true,
    map_c_w = true,
    enable_check_bracket_line = false,
}


-- Remove predefined rules

get_rule( "'" )[1].not_filetypes = {
    "scheme",
    "lisp",
    "racket",
    "rust",
    "nix"
}


-- Common brackets

local Brackets = {
    { '(', ')' },
    { '[', ']' },
    { '{', '}' }
}

local GluedBrackets = {
    "()", "[]", "{}"
}


-- Add a pair of whitespaces when
-- cursor is directly between two brackets
add_rules {

    Rule( ' ', ' ' )
    :with_pair( function( opts )
        local pair = opts.line:sub( opts.col - 1, opts.col )
        return vim.tbl_contains( GluedBrackets, pair )
    end )

}

for _, pair in pairs( Brackets ) do add_rules {

    Rule( pair[1].." ", " "..pair[2] )
    :with_pair( function() return false end )
    :with_move( function( opts )
        return opts.prev_char:match( '.%'..pair[2] ) ~= nil
    end )
    :use_key( pair[2] )

} end


-- Move past commas and semicolons

local Puncts = { ":", ",", ";" }

for _, punct in pairs( Puncts ) do add_rules {

    Rule( "", punct )
    :with_move( function(opts)
        return opts.char == punct
    end )
    :with_pair( function() return false end )
    :with_del( function() return false end )
    :with_cr( function() return false end )
    :use_key( punct )

} end
