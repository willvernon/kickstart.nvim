return {
-- UI: User interface enhancements
  { -- Which Key
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        -- { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        -- { '<leader>d', group = '[D]ocument' },
        -- { '<leader>e', group = '[E]xplore' },
        -- { '<leader>r', group = '[R]ename' },
        -- { '<leader>s', group = '[S]earch' },
        -- { '<leader>w', group = '[W]orkspace' },
        -- { '<leader>t', group = '[T]oggle' },
        -- { '<leader>h', group = '[H]arpoon & [H]elp' },
      },
    },
  },
  
  { -- Highlight TODOs in comments
    'folke/todo-comments.nvim', 
    event = 'VimEnter', 
    dependencies = { 'nvim-lua/plenary.nvim' }, 
    opts = { signs = false },
  },
  
  -- Files: File navigation and management
  { -- Harpoon
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()
    end,
    keys = {
      { '<leader>ha', function() require('harpoon'):list():add() end, desc = 'Add file to Harpoon' },
      { '<leader>h', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Open Harpoon menu' },
      { '<leader>h1', function() require('harpoon'):list():select(1) end, desc = 'Go to Harpoon file 1' },
      { '<leader>h2', function() require('harpoon'):list():select(2) end, desc = 'Go to Harpoon file 2' },
      { '<leader>h3', function() require('harpoon'):list():select(3) end, desc = 'Go to Harpoon file 3' },
      { '<leader>h4', function() require('harpoon'):list():select(4) end, desc = 'Go to Harpoon file 4' },
    },
  },
  { -- Fuzzy finder
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup { -- Configure Telescope
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf') -- Load fzf extension
      pcall(require('telescope').load_extension, 'ui-select') -- Load ui-select extension
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>hs', builtin.help_tags, { desc = '[H]elp page [s]earch' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [k]eymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [f]iles' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind [s]elect Telescope' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [w]ord' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [g]rep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [d]iagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [r]esume' })
      vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>f/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>f//', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>vf', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'Neo[V]im [f]iles' })
      -- I don't want to search in the `docs` directory (rendered quarto output).
      -- table.insert(vimgrep_arguments, '--glob')
      -- table.insert(vimgrep_arguments, '!docs/*')

      -- telescope.setup {
      --   defaults = {
      --     buffer_previewer_maker = new_maker,
      --     vimgrep_arguments = vimgrep_arguments,
      --     file_ignore_patterns = {
      --       'node_modules',
      --       '%_cache',
      --       '.git/',
      --       'site_libs',
      --       '.venv',
      --     },
      --     layout_strategy = 'flex',
      --     sorting_strategy = 'ascending',
      --     layout_config = {
      --       prompt_position = 'top',
      --     },
      --     mappings = {
      --       i = {
      --         ['<C-u>'] = false,
      --         ['<C-d>'] = false,
      --         ['<esc>'] = actions.close,
      --         ['<c-j>'] = actions.move_selection_next,
      --         ['<c-k>'] = actions.move_selection_previous,
      --       },
      --     },
      --   },
      --   pickers = {
      --     find_files = {
      --       hidden = false,
      --       find_command = {
      --         'rg',
      --         '--files',
      --         '--hidden',
      --         '--glob',
      --         '!.git/*',
      --         '--glob',
      --         '!**/.Rpro.user/*',
      --         '--glob',
      --         '!_site/*',
      --         '--glob',
      --         '!docs/**/*.html',
      --         '-L',
      --       },
      --     },
      --   },
      --   extensions = {
      --     ['ui-select'] = {
      --       require('telescope.themes').get_dropdown(),
      --     },
      --     fzf = {
      --       fuzzy = true,                   -- false will only do exact matching
      --       override_generic_sorter = true, -- override the generic sorter
      --       override_file_sorter = true,    -- override the file sorter
      --       case_mode = 'smart_case',       -- or "ignore_case" or "respect_case"
      --     },
      --   },
      -- }
      -- telescope.load_extension 'fzf'
      -- telescope.load_extension 'ui-select'
      -- telescope.load_extension 'dap'
      -- telescope.load_extension 'zotero'
    end,
  },


{ -- nicer-looking tabs with close icons
    'nanozuki/tabby.nvim',
    enabled = false,
    config = function()
      require('tabby.tabline').use_preset 'tab_only'
    end,
  },

  { -- scrollbar
    'dstein64/nvim-scrollview',
    enabled = true,
    opts = {
      current_only = true,
    },
  },

  { -- highlight occurences of current word
    'RRethy/vim-illuminate',
    enabled = false,
  },

  {
    "NStefan002/screenkey.nvim",
    lazy = false,
  },


  { -- show tree of symbols in the current file
    'hedyhli/outline.nvim',
    cmd = 'Outline',
    keys = {
      { '<leader>lo', ':Outline<cr>', desc = 'symbols outline' },
    },
    opts = {
      providers = {
        priority = { 'markdown', 'lsp',  'norg' },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { 'markdown', 'quarto' },
        },
      },
    },
  },

  { -- or show symbols in the current file as breadcrumbs
    'Bekaboo/dropbar.nvim',
    enabled = function()
      return vim.fn.has 'nvim-0.10' == 1
    end,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      -- turn off global option for windowline
      vim.opt.winbar = nil
      vim.keymap.set('n', '<leader>ls', require('dropbar.api').pick, { desc = '[s]ymbols' })
    end,
  },

  { -- terminal
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
    },
  },

  { -- show diagnostics list
    -- PERF: Slows down insert mode if open and there are many diagnostics
    'folke/trouble.nvim',
    enabled = false,
    config = function()
      local trouble = require 'trouble'
      trouble.setup {}
      local function next()
        trouble.next { skip_groups = true, jump = true }
      end
      local function previous()
        trouble.previous { skip_groups = true, jump = true }
      end
      vim.keymap.set('n', ']t', next, { desc = 'next [t]rouble item' })
      vim.keymap.set('n', '[t', previous, { desc = 'previous [t]rouble item' })
    end,
  },
  { -- highlight markdown headings and code blocks etc.
    'lukas-reineke/headlines.nvim',
    enabled = false,
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup {
        quarto = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
          treesitter_language = 'markdown',
        },
        markdown = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
        },
      }
    end,
  },

  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = true,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    cond = function()
      -- Disable on Windows system
       return vim.fn.has 'win32' ~= 1 
    end,
    dependencies = {
       'leafo/magick', -- that's a lua rock
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt install lua5.1
      -- sudo apt install luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            -- only_render_image_at_cursor_mode = "popup",
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = 'normal',
      }

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value('columns', {})
        local win_height = vim.api.nvim_get_option_value('lines', {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })
        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      vim.keymap.set('n', '<leader>io', function()
        local bufnr = vim.api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      vim.keymap.set('n', '<leader>ic', clear_all_images, { desc = 'image [c]lear' })
    end,
  },

}