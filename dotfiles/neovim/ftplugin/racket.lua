local opt = vim.opt_local

opt.lispwords:append
{
  'define/contract',
}

opt.tabstop = 2
opt.softtabstop = 2
opt.virtualedit = "all"

local setkey = vim.keymap.set

setkey( "n", "o", "", {
  silent = true,
  callback = function()
    SameColumnNewline.run( "next" )
  end
} )

setkey( "n", "O", "", {
  silent = true,
  callback = function()
    SameColumnNewline.run( "prev" )
  end
} )
