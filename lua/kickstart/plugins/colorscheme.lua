return {
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    keys = {
      -- { "<leader>tt", "<Cmd>MonokaiToggleLight<CR>", desc = "Monokai-Nightasty: Toggle dark/light theme." },
    },
    ---@module "monokai-nightasty"
    ---@type monokai.UserConfig
    opts = {
      dark_style_background = "dark", -- default, dark, transparent, #RRGGBB
      light_style_background = "default", -- default, dark, transparent, #RRGGBB
      color_headers = true, -- Enable header colors for each header level (h1, h2, etc.)
      lualine_bold = true, -- Lualine a and z sections font width
      lualine_style = "dark", -- "dark", "light" or "default" (Follows dark/light style)
      markdown_header_marks = true, -- Add headers marks highlights (the `#` character) to Treesitter highlight query
      -- Style to be applied to selected syntax groups. See `:help nvim_set_hl`
      hl_styles = {
        keywords = { italic = true },
        comments = { italic = true },
        floats = "dark",
      },

      -- This also could be a table like this: `terminal_colors = { Normal = { fg = "#e6e6e6" } }`
      terminal_colors = function(colors)
        return { fg = colors.fg_dark }
      end,

      --- You can override specific color/highlights. Theme color values
      --- in `extras/palettes`. Also could be any hex RGB color you like.
      on_colors = function(colors)
        if vim.o.background == "light" then
          -- Custom colors for light theme
          colors.comment = "#2d7e79"
          colors.lualine.normal_bg = "#7ebd00"
        else
          -- Custom colors for dark theme
          colors.border = colors.magenta
          colors.lualine.normal_bg = colors.green
        end
      end,

      on_highlights = function(highlights, colors)
        -- You could add styles like bold, underline, italic
        highlights.TelescopeSelection = { bold = true }
        highlights.TelescopeBorder = { fg = colors.grey }
        highlights["@lsp.type.property.lua"] = { fg = colors.fg }
      end,
    },
    config = function(_, opts)
      -- Highlight line at the cursor position
      vim.opt.cursorline = true

      -- Default to dark theme
      vim.o.background = "dark"  -- dark | light

      -- Open new Nvim instances with the light theme when the sun hits the screen
      local date_output = vim.api.nvim_exec2("!date +'\\%H\\%M'", { output = true })
      local system_time = tonumber(string.match(date_output["output"], "%d%d%d%d"))
      -- This sets theme color based on time of day
      -- if system_time >= 1345 and system_time < 1630 then
      --   vim.o.background = "light"
      -- end

      require("monokai-nightasty").load(opts)
    end,
  },
  { 'shaunsingh/nord.nvim', enabled = false, lazy = false, priority = 1000 },
  { 'folke/tokyonight.nvim', enabled = false, lazy = false, priority = 1000 },
  { 'EdenEast/nightfox.nvim', enabled = false, lazy = false, priority = 1000 },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    enabled = false,
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- set colorscheme and overwrite highlights
      vim.cmd.colorscheme 'catppuccin-mocha'
      local colors = require 'catppuccin.palettes.mocha'
      vim.api.nvim_set_hl(0, 'Tabline', { fg = colors.green, bg = colors.mantle })
      vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
    end,
  },

  {
    'oxfist/night-owl.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      require('night-owl').setup()
      vim.cmd.colorscheme 'night-owl'
      vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = 'none',
              },
            },
          },
        },
      }
      vim.cmd.colorscheme 'kanagawa'
      vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })
    end,
  },

  {
    'olimorris/onedarkpro.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
  },

  {
    'neanias/everforest-nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
  },

  -- color html colors
  {
    'NvChad/nvim-colorizer.lua',
    enabled = true,
    opts = {
      filetypes = { '*' },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = 'background', -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = true, -- Enable tailwind colors
        -- parsers can contain values used in |user_default_options|
        sass = { enable = false, parsers = { 'css' } }, -- Enable sass colors
        virtualtext = '■',
        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = false,
        -- all the sub-options of filetypes apply to buftypes
      },
      buftypes = {},
    },
  },
}
