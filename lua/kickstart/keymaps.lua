local wk = require 'which-key'
local ms = vim.lsp.protocol.Methods

-- Debugging shortcut
P = vim.print

-- Global variables for Quarto/R/Python integration
vim.g['quarto_is_r_mode'] = nil
vim.g['reticulate_running'] = false

-- Helper functions for keymaps
local opts = { silent = true, noremap = true } -- Define opts globally to avoid undefined errors
local nmap = function(key, effect, desc)
  vim.keymap.set('n', key, effect, vim.tbl_extend('force', opts, { desc = desc or '' }))
end

local vmap = function(key, effect, desc)
  vim.keymap.set('v', key, effect, vim.tbl_extend('force', opts, { desc = desc or '' }))
end

local imap = function(key, effect, desc)
  vim.keymap.set('i', key, effect, vim.tbl_extend('force', opts, { desc = desc or '' }))
end

local cmap = function(key, effect, desc)
  vim.keymap.set('c', key, effect, vim.tbl_extend('force', opts, { desc = desc or '' }))
end

-- Basic editing keymaps
imap('jj', '<Esc>', '[Exit] insert mode with jj')
vmap('<leader>p', [["_dP]], '[Paste] over selection without yanking')
nmap('<leader>du', [["_d]], '[Delete] without yanking')

-- Maintain selection after indent/dedent
vmap('>', '>gv', '[Indent] and keep selection')
vmap('<', '<gv', '[Dedent] and keep selection')

-- Center cursor after search and jumps
nmap('n', 'nzzzv', '[Search] next, center cursor')
nmap('<C-d>', '<C-d>zzzv', '[Scroll] down, center cursor')
nmap('<C-u>', '<C-u>zzzv', '[Scroll] up, center cursor')

-- Toggle light/dark theme
local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
  -- Optionally reload the colorscheme (e.g., if using a plugin like kanagawa or catppuccin)
  -- vim.cmd.colorscheme(vim.g.colors_name) -- Uncomment if needed
end

-- Navigation and window management
nmap('<Esc>', '<cmd>nohlsearch<CR>', '[Clear] search highlights')
nmap('<leader>q', vim.diagnostic.setloclist, '[Open] diagnostic quickfix list')
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', ops )
nmap('<leader>sh', ':split<CR>', '[Split] horizontal')
nmap('<leader>sv', ':vsplit<CR>', '[Split] vertical')
nmap('<leader>sc', '<C-w>c', '[Close] current split')
nmap('<leader>so', '<C-w>o', '[Close] other splits')

-- Window navigation (already in kickstart, but included for completeness)
nmap('<C-h>', '<C-w>h', '[Move] to left window')
nmap('<C-l>', '<C-w>l', '[Move] to right window')
nmap('<C-j>', '<C-w>j', '[Move] to lower window')
nmap('<C-k>', '<C-w>k', '[Move] to upper window')

-- Terminal creation functions
local function new_terminal(lang)
  vim.cmd('sp term://' .. lang) -- Use horizontal split for terminals (adjust if needed)
end

local new_terminal_python = function()
  new_terminal 'python'
end
local new_terminal_r = function()
  new_terminal 'R --no-save'
end
local new_terminal_ipython = function()
  new_terminal 'ipython --no-confirm-exit'
end
local new_terminal_julia = function()
  new_terminal 'julia'
end
local new_terminal_shell = function()
  new_terminal '$SHELL'
end

-- Otter symbols for multi-language support
local function get_otter_symbols_lang()
  local otterkeeper = require 'otter.keeper'
  local main_nr = vim.api.nvim_get_current_buf()
  local langs = {}
  for i, l in ipairs(otterkeeper.rafts[main_nr].languages or {}) do
    langs[i] = i .. ': ' .. l
  end
  if vim.tbl_isempty(langs) then
    vim.notify('No languages found in current buffer', vim.log.levels.WARN)
    return
  end
  local i = vim.fn.inputlist(langs)
  if i and i > 0 and i <= #langs then
    local lang = otterkeeper.rafts[main_nr].languages[i]
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(),
      otter = { lang = lang },
    }
    vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
  else
    vim.notify('Invalid language selection', vim.log.levels.ERROR)
  end
end

nmap('<leader>os', get_otter_symbols_lang, '[S]ymbols (Otter multi-language)')

-- Quarto-specific functions for sending code to terminals
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    elseif not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

local function send_region()
  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
    slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
    vim.cmd('normal ' .. slime_send_region_cmd)
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    elseif not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
    slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
    vim.cmd('normal ' .. slime_send_region_cmd)
  end
end

-- Keymaps for sending code (consistent with Quarto and vim-slime)
nmap('<C-cr>', send_cell, '[Run] code cell (Ctrl+Enter)')
nmap('<S-cr>', send_cell, '[Run] code cell (Shift+Enter)')
imap('<C-cr>', send_cell, '[Run] code cell from insert mode (Ctrl+Enter)')
imap('<S-cr>', send_cell, '[Run] code cell from insert mode (Shift+Enter)')
vmap('<CR>', send_region, '[Run] selected region')

-- Show R dataframe in browser
local function show_r_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  if not node then
    vim.notify('No symbol found under cursor', vim.log.levels.WARN)
    return
  end
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

nmap('<leader>rt', show_r_table, '[T]able (show R dataframe in browser)')

-- Insert code chunks using Otter
local function is_code_chunk()
  local current, _ = require('otter.keeper').get_current_language_context()
  return current ~= nil
end

local function insert_code_chunk(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<CR><CR>```{]] .. lang .. [[}<Esc>O]]
  else
    keys = [[o```{]] .. lang .. [[}<CR>```<Esc>O]]
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
end

local insert_r_chunk = function()
  insert_code_chunk 'r'
end
local insert_py_chunk = function()
  insert_code_chunk 'python'
end
local insert_lua_chunk = function()
  insert_code_chunk 'lua'
end
local insert_julia_chunk = function()
  insert_code_chunk 'julia'
end
local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end
local insert_ojs_chunk = function()
  insert_code_chunk 'ojs'
end

-- Which-key insert mode mappings
wk.add({
  {
    mode = 'i',
    { '<C-x><C-x>', '<C-x><C-o>', desc = '[Complete] omnifunc' },
    { '<M-->', ' <- ', desc = '[Assign] (R-style)' },
    { '<M-m>', ' |> ', desc = '[Pipe] (R-style)' },
  },
}, { mode = 'i' })

-- Which-key visual mode mappings
wk.add({
  {
    mode = 'v',
    { '.', ':norm .<CR>', desc = '[Repeat] last normal command' },
    { '<M-j>', ":m'>+<CR>`<my`>mzgv`yo`z", desc = '[Move] line down' },
    { '<M-k>', ":m'<-2<CR>`>my`<mzgv`yo`z", desc = '[Move] line up' },
    { '<CR>', send_region, desc = '[Run] selected region' },
    { 'q', ':norm @q<CR>', desc = '[Repeat] q macro' },
  },
}, { mode = 'i' })

-- Ensure which-key shows all keymaps
wk.setup {
  plugins = { spelling = true },
  window = { border = 'rounded' },
}

-- Which-key normal mode mappings (grouped by prefix)
wk.add {
  -- General navigation and editing
  { '<C-LeftMouse>', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = '[Go to] definition (mouse)' },
  { '<C-q>', '<cmd>q<CR>', desc = '[Close] buffer' },
  { '<Esc>', '<cmd>nohl<CR>', desc = '[Clear] search highlights' },
  { '[q', ':silent cprev<CR>', desc = '[Quickfix] previous' },
  { ']q', ':silent cnext<CR>', desc = '[Quickfix] next' },
  { 'gN', 'Nzzzv', desc = '[Search] previous, center cursor' },
  { 'gf', ':e <cfile><CR>', desc = '[Edit] file under cursor' },
  { 'gl', '<C-]>', desc = '[Open] help link' },
  { 'z?', ':setlocal spell!<CR>', desc = '[Toggle] spellcheck' },
  { 'zl', ':Telescope spell_suggest<CR>', desc = '[List] spelling suggestions' },

  -- Leader mappings with groups
  {
    mode = 'n',
    { '<leader>c', group = '[C]ode / [C]ell / [C]hunk' },
    { '<leader>d', group = '[D]ebug' },
    { '<leader>dt', group = '[t]est' },
    { '<leader>e', group = '[E]xplore / [E]dit' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]plit' },
    { '<leader>f', group = '[F]ind (Telescope)' },
    { '<leader>g', group = '[G]it' },
    { '<leader>gb', group = '[b]lame' },
    { '<leader>gd', group = '[d]iff' },
    { '<leader>h', group = '[H]arpoon & [H]elp' },
    { '<leader>hc', group = '[c]onceal' },
    { '<leader>ht', group = '[t]reesitter' },
    { '<leader>i', group = '[I]mage' },
    { '<leader>l', group = '[L]anguage / LSP' },
    { '<leader>n', group = '[N]otes' },
    { '<leader>q', group = '[Q]uarto' },
    { '<leader>qr', group = '[r]un' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>u', group = '[U]I' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>v', group = '[V]im' },
    { '<leader>x', group = '[X]ecute' },

    -- Specific leader keymaps
    { '<leader>um', '<cmd>:message<CR>', desc = '[U]I Notification Message' },
    { '<leader><cr>', send_cell, desc = '[Run] code cell' },
    { '<leader>ci', new_terminal_ipython, desc = '[New] IPython terminal' },
    { '<leader>cj', new_terminal_julia, desc = '[New] Julia terminal' },
    { '<leader>cn', new_terminal_shell, desc = '[New] shell terminal' },
    { '<leader>cp', new_terminal_python, desc = '[New] Python terminal' },
    { '<leader>cr', new_terminal_r, desc = '[New] R terminal' },
    { '<leader>f ', '<cmd>Telescope buffers<CR>', desc = '[ ] Find buffers' },
    { '<leader>fM', '<cmd>Telescope man_pages<CR>', desc = '[M]an pages' },
    { '<leader>fb', '<cmd>Telescope current_buffer_fuzzy_find<CR>', desc = '[B]uffer fuzzy find' },
    { '<leader>fc', '<cmd>Telescope git_commits<CR>', desc = '[C]ommits' },
    { '<leader>fd', '<cmd>Telescope buffers<CR>', desc = '[D]iagnostics (buffers)' },
    { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = '[F]iles' },
    { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = '[G]rep' },
    { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = '[H]elp' },
    { '<leader>fj', '<cmd>Telescope jumplist<CR>', desc = '[J]umplist' },
    { '<leader>fk', '<cmd>Telescope keymaps<CR>', desc = '[K]eymaps' },
    { '<leader>fl', '<cmd>Telescope loclist<CR>', desc = '[L]oclist' },
    { '<leader>fm', '<cmd>Telescope marks<CR>', desc = '[M]arks' },
    { '<leader>fq', '<cmd>Telescope quickfix<CR>', desc = '[Q]uickfix' },
    { '<leader>gbb', ':GitBlameToggle<CR>', desc = '[B]lame toggle virtual text' },
    { '<leader>gbc', ':GitBlameCopyCommitURL<CR>', desc = '[C]opy commit URL' },
    { '<leader>gbo', ':GitBlameOpenCommitURL<CR>', desc = '[O]pen commit URL' },
    { '<leader>gc', ':GitConflictRefresh<CR>', desc = '[C]onflict refresh' },
    { '<leader>gdc', ':DiffviewClose<CR>', desc = '[C]lose Diffview' },
    { '<leader>gdo', ':DiffviewOpen<CR>', desc = '[O]pen Diffview' },
    { '<leader>gs', ':Gitsigns<CR>', desc = '[S]igns (Git)' },
    { '<leader>gwc', ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", desc = '[C]reate git worktree' },
    { '<leader>gws', ":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", desc = '[S]witch git worktree' },
    { '<leader>hch', ':set conceallevel=1<CR>', desc = '[H]ide conceal' },
    { '<leader>hcs', ':set conceallevel=0<CR>', desc = '[S]how unconceal' },
    { '<leader>htt', vim.treesitter.inspect_tree, desc = '[T]reesitter inspect tree' },
    { '<leader>la', vim.lsp.buf.code_action, desc = '[A]ction (LSP code action)' },
    { '<leader>ld', group = '[D]iagnostics' },
    {
      '<leader>ldd',
      function()
        vim.diagnostic.enable(false)
      end,
      desc = '[D]isable diagnostics',
    },
    { '<leader>lde', vim.diagnostic.enable, desc = '[E]nable diagnostics' },
    { '<leader>le', vim.diagnostic.open_float, desc = '[E]rror (show diagnostic hover)' },
    { '<leader>lg', ':Neogen<CR>', desc = '[G]enerate docstring' },
    { '<leader>o', group = '[O]tter & [C]ode' },
    { '<leader>oa', require('otter').activate, desc = '[A]ctivate Otter' },
    { '<leader>ob', insert_bash_chunk, desc = '[B]ash code chunk' },
    { '<leader>oc', 'O# %%<CR>', desc = '[C]reate magic comment chunk (# %%)' },
    { '<leader>od', require('otter').activate, desc = '[D]eactivate Otter' }, -- Assuming you want to toggle
    { '<leader>oj', insert_julia_chunk, desc = '[J]ulia code chunk' },
    { '<leader>ol', insert_lua_chunk, desc = '[L]ua code chunk' },
    { '<leader>oo', insert_ojs_chunk, desc = '[O]JS code chunk' },
    { '<leader>op', insert_py_chunk, desc = '[P]ython code chunk' },
    { '<leader>or', insert_r_chunk, desc = '[R] code chunk' },
    {
      '<leader>qE',
      function()
        require('otter').export(true)
      end,
      desc = '[E]xport with overwrite (Otter)',
    },
    { '<leader>qa', ':QuartoActivate<CR>', desc = '[A]ctivate Quarto' },
    { '<leader>qe', require('otter').export, desc = '[E]xport (Otter)' },
    { '<leader>qh', ':QuartoHelp ', desc = '[H]elp (Quarto)' },
    { '<leader>qp', ":lua require('quarto').quartoPreview()<CR>", desc = '[P]review Quarto document' },
    { '<leader>qq', ":lua require('quarto').quartoClosePreview()<CR>", desc = '[Q]uit Quarto preview' },
    { '<leader>qra', ':QuartoSendAll<CR>', desc = '[A]ll (Quarto run all)' },
    { '<leader>qrb', ':QuartoSendBelow<CR>', desc = '[B]elow (Quarto run below)' },
    { '<leader>qrr', ':QuartoSendAbove<CR>', desc = '[R]un to cursor (Quarto)' },
    { '<leader>rt', show_r_table, desc = '[T]able (show R dataframe in browser)' },
    { '<leader>vc', ':Telescope colorscheme<CR>', desc = '[C]olorscheme (Telescope)' },
    { '<leader>vh', ':execute "h " . expand("<cword>")<CR>', desc = '[H]elp for current word' },
    { '<leader>vl', ':Lazy<CR>', desc = '[L]azy plugin manager' },
    { '<leader>vm', ':Mason<CR>', desc = '[M]ason tool installer' },
    { '<leader>vs', ':e $MYVIMRC | :cd %:p:h | split . | wincmd k<CR>', desc = '[S]ettings (edit vimrc)' },
    { '<leader>vt', toggle_light_dark_theme, desc = '[T]oggle light/dark theme' },
    { '<leader>xx', ':w<CR>:source %<CR>', desc = '[X] Source current file' },
  },
}
