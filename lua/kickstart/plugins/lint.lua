return {

   { -- Linting
      'mfussenegger/nvim-lint',
      event = { 'BufReadPre', 'BufNewFile' },
      config = function()
         local lint = require 'lint'
         lint.linters_by_ft = {
            markdown = { 'markdownlint' },
         }

         -- To allow other plugins to add linters to require('lint').linters_by_ft,
         -- instead set linters_by_ft like this:
         -- lint.linters_by_ft = lint.linters_by_ft or {}
         -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
         --
         -- However, note that this will enable a set of default linters,
         -- which will cause errors unless these tools are available:
         -- {
         --   clojure = { "clj-kondo" },
         --   dockerfile = { "hadolint" },
         --   inko = { "inko" },
         --   janet = { "janet" },
         --   json = { "jsonlint" },
         --   markdown = { "vale" },
         --   rst = { "vale" },
         --   ruby = { "ruby" },
         --   terraform = { "tflint" },
         --   text = { "vale" }
         -- }
         --
         -- You can disable the default linters by setting their filetypes to nil:
         -- lint.linters_by_ft['clojure'] = nil
         -- lint.linters_by_ft['dockerfile'] = nil
         -- lint.linters_by_ft['inko'] = nil
         -- lint.linters_by_ft['janet'] = nil
         -- lint.linters_by_ft['json'] = nil
         -- lint.linters_by_ft['markdown'] = nil
         -- lint.linters_by_ft['rst'] = nil
         -- lint.linters_by_ft['ruby'] = nil
         -- lint.linters_by_ft['terraform'] = nil
         -- lint.linters_by_ft['text'] = nil

         -- Create autocommand which carries out the actual linting
         -- on the specified events.
         local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
         vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_augroup,
            callback = function()
               -- Only run the linter in buffers that you can modify in order to
               -- avoid superfluous noise, notably within the handy LSP pop-ups that
               -- describe the hovered symbol using Markdown.
               if vim.opt_local.modifiable:get() then
                  lint.try_lint()
               end
            end,
         })
      end,
   },
   { -- Autoformatting
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      keys = {
         {
            '<leader>cf',
            function()
               require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = '',
            desc = '[F]ormat buffer',
         },
      },
      opts = {
         notify_on_error = false,
         format_on_save = function(bufnr) -- Format on save settings
            local disable_filetypes = { c = true, cpp = true }
            local lsp_format_opt
            if disable_filetypes[vim.bo[bufnr].filetype] then
               lsp_format_opt = 'never'
            else
               lsp_format_opt = 'fallback'
            end
            return {
               timeout_ms = 500,
               lsp_format = lsp_format_opt,
            }
         end,
         formatters_by_ft = {
            lua = { 'stylua' }, -- Format Lua with stylua
            python = { 'black' }, -- Format Python with black
            r = { 'styler' }, -- Format R with styler
            markdown = { 'prettier' }, -- Format Markdown with prettier
         },
         lang_to_ext = {
            bash = 'sh',
            c_sharp = 'cs',
            elixir = 'exs',
            javascript = 'js',
            julia = 'jl',
            latex = 'tex',
            markdown = 'md',
            python = 'py',
            ruby = 'rb',
            rust = 'rs',
            teal = 'tl',
            r = 'r',
            lua = 'lua',
            typescript = 'ts',
         },
      },
   },
}
