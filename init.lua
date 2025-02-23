-- Load global settings first
require 'kickstart.global' -- Load global Neovim settings
-- Autocommand for highlighting yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Work around jupytext needing R not r files case sensitive
-- vim.api.nvim_create_autocmd("BufReadCmd", {
--   pattern = "*.ipynb",
--   callback = function()
--     local input_path = vim.fn.expand("<afile>")
--     local output_path = input_path:gsub("%.ipynb$", ".R")
--     vim.fn.system("jupytext '" .. input_path .. "' --output='" .. output_path .. "' --to=R:percent")
--     vim.cmd("edit " .. output_path)
--   end,
-- })

-- Setup lazy.nvim plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins with lazy.nvim
require('lazy').setup({
  {
    'folke/which-key.nvim', -- Show pending keybinds
    event = 'VimEnter',
    config = function()
      require('which-key').setup {}
      require 'kickstart.keymaps' -- Moved here to load after which-key
    end,
  },
  { import = 'kickstart.plugins.code' },
  { import = 'kickstart.plugins.colorscheme' },
  { import = 'kickstart.plugins.debug' },
  { import = 'kickstart.plugins.dev' },
  { import = 'kickstart.plugins.editor' },
  { import = 'kickstart.plugins.git' },
  { import = 'kickstart.plugins.lint' },
  { import = 'kickstart.plugins.lsp' },
  { import = 'kickstart.plugins.mini' },
  -- { import = 'kickstart.plugins.neo-tree' }, -- Uncomment if needed
  { import = 'kickstart.plugins.notes' },
  { import = 'kickstart.plugins.quarto' },
  { import = 'kickstart.plugins.treesitter' },
  { import = 'kickstart.plugins.ui' },
  { import = 'kickstart.plugins.welcome-screen' },
  { import = 'kickstart.plugins.workspaces' },
}, {
  ui = { -- Lazy.nvim UI settings
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
