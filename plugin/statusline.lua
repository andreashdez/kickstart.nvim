vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }

local colors = require('catppuccin.palettes').get_palette 'mocha'

local function wider_than(n)
  return function() return vim.fn.winwidth(0) > n end
end

local function hl(fg) return { fg = fg, bg = colors.base } end

-- Used in both active and inactive sections
local evil_catppuccin_mode = {
  function() return '▋' end,
  padding = { left = 0, right = 1 },
}

local evil_catppuccin_filename = {
  'filename',
  path = 4,
  file_status = false,
  -- red when readonly, peach when modified
  color = function() return { fg = vim.bo.readonly and colors.red or vim.bo.modified and colors.peach or nil, gui = 'bold' } end,
  cond = function() return vim.fn.expand '%:t' ~= '' and wider_than(40)() end,
}

require('lualine').setup {
  options = {
    section_separators = '',
    component_separators = '',
    -- Only section `a` (the mode bar) changes colour with the mode
    theme = {
      normal = { a = hl(colors.blue), b = hl(colors.text), c = hl(colors.text) },
      insert = { a = hl(colors.green) },
      visual = { a = hl(colors.pink) },
      replace = { a = hl(colors.red) },
      command = { a = hl(colors.peach) },
      terminal = { a = hl(colors.peach) },
      inactive = { a = hl(colors.surface2), b = hl(colors.surface2), c = hl(colors.surface2) },
    },
  },
  sections = {
    lualine_a = { evil_catppuccin_mode },
    lualine_b = {
      { 'filetype', icon_only = true, icon = { align = 'left' }, padding = { left = 1, right = 0 } },
      evil_catppuccin_filename,
    },
    lualine_c = {
      {
        function()
          local client = vim.lsp.get_clients({ bufnr = 0 })[1]
          return client and '[' .. client.name .. ']' or ''
        end,
        color = { gui = 'bold' },
        padding = { left = 2, right = 1 },
        cond = wider_than(40),
      },
      {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        diagnostics_color = {
          error = { fg = colors.red, gui = 'bold' },
          warn = { fg = colors.peach, gui = 'bold' },
          info = { fg = colors.blue, gui = 'bold' },
          hint = { fg = colors.blue, gui = 'bold' },
        },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        cond = wider_than(40),
      },
    },
    lualine_x = {
      'searchcount',
      {
        'diff',
        -- Reuse gitsigns' hunk counts instead of having lualine run `git diff` itself
        source = function()
          local g = vim.b.gitsigns_status_dict
          if g then return { added = g.added, modified = g.changed, removed = g.removed } end
        end,
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.peach },
          removed = { fg = colors.red },
        },
        symbols = { added = ' ', modified = ' ', removed = ' ' },
        cond = wider_than(80),
      },
      { 'branch', icon = '', color = { gui = 'bold' }, cond = wider_than(40) },
    },
    lualine_y = { { 'location', padding = { left = 2, right = 2 }, cond = wider_than(40) } },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = { evil_catppuccin_mode },
    lualine_b = { evil_catppuccin_filename },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}
