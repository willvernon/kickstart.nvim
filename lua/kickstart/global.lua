-- global options

-- Set leader keys and Nerd Font support
vim.g.mapleader = ' ' -- Space as leader key
vim.g.maplocalleader = ' ' -- Space as local leader key
vim.g.have_nerd_font = true -- Enable Nerd Font support

-- Editor options
vim.opt.number = true -- Show line numbers
vim.opt.mouse = 'a' -- Enable mouse support
vim.opt.mousefocus = true
vim.opt.showmode = false -- Hide mode in command line
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus' -- Sync clipboard with OS
end)
vim.opt.breakindent = true -- Indent wrapped lines
vim.opt.smartindent = true
vim.opt.undofile = true -- Persistent undo
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true -- Case-sensitive if capitals used
vim.opt.signcolumn = 'yes' -- Always show sign column
vim.opt.updatetime = 250 -- Faster update time
vim.opt.timeoutlen = 300 -- Shorter key sequence wait
vim.opt.splitright = true -- New vertical splits go right
vim.opt.splitbelow = true -- New horizontal splits go below
vim.opt.list = true -- Show whitespace characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Define whitespace characters
vim.opt.inccommand = 'split' -- Live preview for substitutions
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 10 -- Keep lines visible above/below cursor

-- proper colors
vim.opt.termguicolors = true

-- show insert mode in terminal buffers
vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })

-- disable fill chars (the ~ after the buffer)
vim.o.fillchars = 'eob: '

-- don't ask about existing swap files
vim.opt.shortmess:append 'A'

-- mode is already in statusline
vim.opt.showmode = false

-- use less indentation
local tabsize = 3
vim.opt.expandtab = true
vim.opt.shiftwidth = tabsize
vim.opt.tabstop = tabsize

-- smarter search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- how to show autocomplete menu
vim.opt.completeopt = 'menuone,noinsert'

-- global statusline
vim.opt.laststatus = 3

vim.cmd [[
let g:currentmode={
       \ 'n'  : '%#String# NORMAL ',
       \ 'v'  : '%#Search# VISUAL ',
       \ 's'  : '%#ModeMsg# VISUAL ',
       \ "\<C-V>" : '%#Title# V·Block ',
       \ 'V'  : '%#IncSearch# V·Line ',
       \ 'Rv' : '%#String# V·Replace ',
       \ 'i'  : '%#ModeMsg# INSERT ',
       \ 'R'  : '%#Substitute# R ',
       \ 'c'  : '%#CurSearch# Command ',
       \ 't'  : '%#ModeMsg# TERM ',
       \}
]]

-- hide cmdline when not used
vim.opt.cmdheight = 1

--tabline
vim.opt.showtabline = 1

--windowline
vim.opt.winbar = '%f'

-- don't continue comments automagically
-- https://neovim.io/doc/user/options.html#'formatoptions'
vim.opt.formatoptions:remove 'c'
vim.opt.formatoptions:remove 'r'
vim.opt.formatoptions:remove 'o'


-- (don't == 0) replace certain elements with prettier ones
vim.opt.conceallevel = 0

-- diagnostics
vim.diagnostic.config {
  virtual_text = true,
  underline = true,
  signs = true,
}

-- add new filetypes
vim.filetype.add {
  extension = {
    ojs = 'javascript',
  },
}

-- additional builtin vim packages
-- filter quickfix list with Cfilter
vim.cmd.packadd 'cfilter'
