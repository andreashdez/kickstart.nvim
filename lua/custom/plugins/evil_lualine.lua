-- stylua: ignore
local colors = {
  bg       = '#282830',
  fg       = '#cccccc',
  blue     = '#66bbff',
  cyan     = '#66ddff',
  green    = '#77bb66',
  grey     = '#525266',
  magenta  = '#cc99ff',
  red      = '#ee5588',
  yellow   = '#ffaa66',
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand '%:t') ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
}

local evil_theme = {
  command = { a = { fg = colors.yellow, bg = colors.bg } },
  inactive = {
    a = { fg = colors.grey, bg = colors.bg },
    b = { fg = colors.grey, bg = colors.bg },
    c = { fg = colors.grey, bg = colors.bg },
  },
  normal = {
    a = { fg = colors.blue, bg = colors.bg },
    b = { fg = colors.fg, bg = colors.bg },
    c = { fg = colors.fg, bg = colors.bg },
  },
  insert = { a = { fg = colors.green, bg = colors.bg } },
  replace = { a = { fg = colors.red, bg = colors.bg } },
  terminal = { a = { fg = colors.yellow, bg = colors.bg } },
  visual = { a = { fg = colors.magenta, bg = colors.bg } },
}

local evil_mode = {
  function()
    return '▋ '
  end,
  padding = { left = 0, right = 2 },
}

local evil_filename = {
  'filename',
  file_status = false,
  path = 4,
  color = { gui = 'bold' },
  cond = conditions.buffer_not_empty,
}

local evil_lsp = {
  function()
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return ''
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return '[' .. client.name .. ']'
      end
    end
    return ''
  end,
  color = { gui = 'bold' },
  padding = { left = 2, right = 1 },
}

local evil_diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  diagnostics_color = {
    error = { fg = colors.red, gui = 'bold' },
    warn = { fg = colors.yellow, gui = 'bold' },
    info = { fg = colors.blue, gui = 'bold' },
    hint = { fg = colors.blue, gui = 'bold' },
  },
  symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
}

local evil_diff = {
  'diff',
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  },
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  cond = conditions.hide_in_width,
}

local evil_branch = {
  'branch',
  icon = '',
  color = { gui = 'bold' },
}

local evil_location = {
  'location',
  padding = { left = 2, right = 2 },
}

local options = {
  options = {
    section_separators = '',
    component_separators = '',
    theme = evil_theme,
  },
  sections = {
    lualine_a = { evil_mode },
    lualine_b = { evil_filename },
    lualine_c = { evil_lsp, evil_diagnostics },
    lualine_x = { 'searchcount', evil_diff, evil_branch },
    lualine_y = { evil_location },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = { evil_mode },
    lualine_b = { evil_filename },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
}

return {
  'nvim-lualine/lualine.nvim',
  opts = options,
}
