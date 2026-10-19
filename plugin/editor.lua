vim.pack.add {
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/which-key.nvim',
}

require('guess-indent').setup {}

require('which-key').setup {
  delay = 0,
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions' },
  },
}

-- mini.nvim is added in init.lua
require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.indentscope').setup {
  symbol = '▏',
  draw = { animation = require('mini.indentscope').gen_animation.none() },
}
