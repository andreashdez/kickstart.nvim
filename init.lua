-- Plugins are configured in plugin/*.lua, which Neovim sources automatically after this file.
-- Anything those files depend on (leader, colorscheme, icons, build hooks) lives here.

vim.loader.enable()

-- External tools are installed with mise (see tools.toml); expose them regardless of how nvim was launched
local mise_data = vim.env.MISE_DATA_DIR or ((vim.env.XDG_DATA_HOME or vim.fn.expand '~/.local/share') .. '/mise')
vim.env.PATH = mise_data .. '/shims:' .. vim.env.PATH

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Options ]]
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- [[ Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function() vim.hl.on_yank() end,
})

-- [[ Diagnostics ]]
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  },
  virtual_text = false,
  virtual_lines = { current_line = true, source = 'if_many', spacing = 2 },
  jump = {
    on_jump = function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false } end,
  },
}

-- [[ Plugin build hooks ]]
-- Must be registered before any vim.pack.add() so it also runs on first install.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end
    if name == 'telescope-fzf-native.nvim' then
      local result = vim.system({ 'make' }, { cwd = ev.data.path }):wait()
      if result.code ~= 0 then vim.notify('Build failed for ' .. name .. ':\n' .. (result.stderr or ''), vim.log.levels.ERROR) end
    elseif name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

-- [[ Colorscheme and icons ]]
vim.pack.add {
  'https://github.com/catppuccin/nvim',
  'https://github.com/nvim-mini/mini.nvim',
}

require('catppuccin').setup {
  transparent_background = true,
  custom_highlights = function(c)
    return {
      CursorLine = { bg = c.surface0 },
      CursorLineNr = { bg = c.surface0 },
      CursorLineSign = { bg = c.surface0 },
    }
  end,
}
vim.cmd.colorscheme 'catppuccin-mocha'

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()
