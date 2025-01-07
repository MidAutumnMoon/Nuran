local state_dir = vim.fn.stdpath 'state'

local options = {

    number = true,
    relativenumber = true,
    mouse = "n",

    lazyredraw = true,
    timeoutlen = 300,
    updatetime = 500,

    laststatus = 3,

    autoread = true,
    autowrite = true,
    autowriteall = true,

    scrolloff = 10,

    startofline = true,
    joinspaces = false,
    virtualedit = "block",
    whichwrap = "b,s,<,>,[,]",

    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 0,
    smarttab = true,
    expandtab = true,
    autoindent = true,

    completeopt = "menuone,preview,longest",
    diffopt = "filler,vertical",

    showbreak = "↳ ",
    breakindent = false,
    breakindentopt = "sbr",

    synmaxcol = 600,
    termguicolors = true,
    cursorline = true,
    visualbell = true,
    fillchars = {
        eob = " ",
        -- vert = " ",
    },
    signcolumn = "yes:1",
    nrformats = "hex,bin,unsigned",

    list = true,
    listchars = {
        tab = "▷ ",
        trail = "·",
        extends = "◣",
    },

    showcmd = true,

    wildmenu = true,
    wildmode = "full:lastused",

    ignorecase = true,
    smartcase = true,
    hlsearch = true,
    incsearch = true,

    swapfile = true,
    directory = state_dir .. "/swap//",
    writebackup = true,
    backup = false,
    backupdir = state_dir .. "/backup//",
    undofile = true,
    undodir = state_dir .. "/undo//",

    foldmethod = "marker",
    foldlevelstart = 99,

    shell = "/bin/sh",

    smoothscroll = true,

}

for option, value in pairs( options ) do
    vim.opt[option] = value
end

vim.opt.shortmess:append("IF")
vim.opt.formatoptions:append("1,j")

