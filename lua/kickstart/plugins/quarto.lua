return {
  -- Quarto Support with Language Features
  {
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' }, -- Trigger on Quarto files only
    dependencies = {
      -- Otter for multi-language support (Python, R, etc.) in Quarto
      'jmbuhr/otter.nvim',
      -- Treesitter for syntax highlighting and parsing
      'nvim-treesitter/nvim-treesitter',
      -- LSP for language features (configured in lsp.lua)
      'neovim/nvim-lspconfig',
    },
    opts = {
      -- Optional: Quarto-specific options
      lsp = { enabled = true }, -- Enable LSP for Quarto
      keymap = {
        hover = 'K', -- Default keymap for hover (customize as needed)
        definition = 'gd', -- Go to definition
      },
    },
    config = function()
      require('quarto').setup {}
    end,
  },

  -- Jupytext for Jupyter Notebook (.ipynb) Support
  {
    'GCBallesteros/jupytext.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- Required for filetype detection
    lazy = false, -- Load immediately for .ipynb files
    config = function()
      require('jupytext').setup {
        style = 'hydrogen', -- Use Hydrogen-style (# %%) for plain text
        output_extension = 'auto', -- Auto-select extension (e.g., .py, .R, .qmd)
        force_ft = nil, -- Use Neovim’s default filetype detection
        custom_language_formatting = {
          python = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' }, -- Python as .py
          R = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' }, -- R as .R (uppercase for Jupytext)
          markdown = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' }, -- Markdown as .md
          quarto = { extension = 'qmd', style = 'quarto', force_ft = 'quarto' }, -- Quarto as .qmd
        },
        autosync = true, -- Automatically sync .ipynb with plain text
      }

      -- Autocommand to handle .ipynb files
      vim.api.nvim_create_autocmd('BufReadCmd', {
        pattern = '*.ipynb',
        callback = function()
          local input_path = vim.fn.expand '<afile>'
          local output_path = require('jupytext').get_output_path(input_path)
          vim.fn.system("jupytext '" .. input_path .. "' --output='" .. output_path .. "' --to=" .. require('jupytext').get_style())
          vim.cmd('edit ' .. output_path)
        end,
      })
    end,
  },

  -- vim-slime for Sending Code to Terminals/REPLs
  {
    'jpalardy/vim-slime',
    init = function()
      -- Initialize global variables for Quarto/R/Python handling
      vim.g.slime_target = 'neovim' -- Use Neovim terminal as target
      vim.g.slime_no_mappings = true -- Disable default mappings to use custom ones
      vim.g.slime_python_ipython = 1 -- Enable IPython support for Python
      vim.g.slime_dispatch_ipython_pause = 100 -- Delay for IPython paste

      -- Function to check if in a Python chunk using Otter
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        return require('otter.tools.functions').is_otter_language_context 'python'
      end

      -- Custom escape function for vim-slime in Quarto
      vim.cmd [[
        function! SlimeOverride_EscapeText_quarto(text)
          call v:lua.Quarto_is_in_python_chunk()
          if exists('g:slime_python_ipython') && len(split(a:text, "\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
            return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
          elseif exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
            return [a:text, "\n"]
          else
            return [a:text]
          end
        endfunction
      ]]
    end,
    config = function()
      -- Configure vim-slime settings
      vim.g.slime_input_pid = false -- Don’t require PID input
      vim.g.slime_suggest_default = true -- Suggest default terminal
      vim.g.slime_menu_config = false -- Disable menu config
      vim.g.slime_neovim_ignore_unlisted = true -- Ignore unlisted buffers

      -- Keymaps for marking and setting the terminal
      local function mark_terminal()
        local job_id = vim.b.terminal_job_id
        if job_id then
          vim.print('Marked terminal job_id: ' .. job_id)
          vim.g.slime_config = { jobid = job_id } -- Store job ID for vim-slime
        else
          vim.notify('No terminal job ID found in current buffer', vim.log.levels.WARN)
        end
      end

      local function set_terminal()
        vim.fn.call('slime#config', {})
      end

      vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal for slime' })
      vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal for slime' })

      -- Add keymaps for sending code (consistent with your keymaps.lua)
      vim.keymap.set('n', '<c-cr>', function()
        vim.fn['slime#send_cell']()
      end, { desc = 'Send code cell to terminal' })
      vim.keymap.set('n', '<s-cr>', function()
        vim.fn['slime#send_cell']()
      end, { desc = 'Send code cell to terminal (Shift+Enter)' })
      vim.keymap.set('i', '<c-cr>', function()
        vim.fn['slime#send_cell']()
      end, { desc = 'Send code cell from insert mode' })
      vim.keymap.set('i', '<s-cr>', function()
        vim.fn['slime#send_cell']()
      end, { desc = 'Send code cell from insert mode (Shift+Enter)' })
    end,
  },

  -- Image Paste and Drag-and-Drop for Markdown/Quarto/LaTeX
  {
    'HakonHarnes/img-clip.nvim',
    event = 'BufEnter',
    ft = { 'markdown', 'quarto', 'latex' },
    opts = {
      default = {
        dir_path = 'img', -- Store images in an 'img' directory
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)', -- Markdown image template
          drag_and_drop = {
            download_images = false, -- Don’t download images automatically
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![]($FILE_PATH){#fig-$RANDOM}', -- Quarto image with figure ID
          drag_and_drop = {
            download_images = false,
          },
        },
        latex = {
          url_encode_path = true,
          template = '\\includegraphics{$FILE_PATH}', -- LaTeX image template
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require('img-clip').setup(opts)
      vim.keymap.set('n', '<leader>ii', ':PasteImage<CR>', { desc = '[i]nsert [i]mage from clipboard' })
    end,
  },

  -- Equation Preview with Nabla
  {
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require("nabla").toggle_virt()<CR>', desc = 'Toggle [m]ath equations preview' },
    },
    config = function()
      require('nabla').enable_virt() -- Enable virtual text for equations by default
    end,
  },

  -- Molten for Code Cell Execution (Disabled by Default)
  {
    'benlubas/molten-nvim',
    enabled = false, -- Disabled to avoid conflicts or performance issues
    build = ':UpdateRemotePlugins',
    init = function()
      -- Configure Molten settings
      vim.g.molten_image_provider = 'image.nvim' -- Use image.nvim for rendering
      vim.g.molten_output_win_max_height = 20 -- Limit output window height
      vim.g.molten_auto_open_output = false -- Don’t auto-open output window
    end,
    keys = {
      { '<leader>mi', ':MoltenInit<CR>', desc = '[m]olten [i]nit' },
      { '<leader>mv', ':<C-u>MoltenEvaluateVisual<CR>', mode = 'v', desc = 'Molten evaluate visual selection' },
      { '<leader>mr', ':MoltenReevaluateCell<CR>', desc = 'Molten re-evaluate cell' },
    },
    config = function()
      require('molten').setup {
        auto_open_output = false, -- Manual control over output
        image_provider = 'image.nvim', -- Ensure image.nvim is installed
      }
    end,
  },
}
