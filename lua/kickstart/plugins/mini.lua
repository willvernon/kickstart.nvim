return {
    {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
      require('mini.files').setup {
        -- General options
  options = {
    -- Whether to delete permanently or move into module-specific trash
    permanent_delete = true,
    -- Whether to use for editing directories
    use_as_default_explorer = false,
  },

        windows = {
          max_number = math.huge,
          preview = true,
          width_focus = 20,
          width_nofocus = 15,
          width_preview = 25,
        },
      }
      vim.keymap.set('n', '<leader>ee', '<cmd>:lua MiniFiles.open()<CR>', { desc = 'Open MiniFiles' })
    end,
  },
}