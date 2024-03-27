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
  hide_in_width_80 = function()
    return vim.fn.winwidth(0) > 80
  end,
  hide_in_width_40 = function()
    return vim.fn.winwidth(0) > 40
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
    -- return '▋ '
    return '▋'
  end,
  padding = { left = 0, right = 1 },
}

local evil_filetype = {
  'filetype',
  icon_only = true,
  icon = { align = 'left' },
  padding = { left = 1, right = 0 },
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
  cond = conditions.hide_in_width_40,
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
  cond = conditions.hide_in_width_40,
}

local evil_diff = {
  'diff',
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.yellow },
    removed = { fg = colors.red },
  },
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  cond = conditions.hide_in_width_80,
}

local evil_branch = {
  'branch',
  icon = '',
  color = { gui = 'bold' },
  cond = conditions.hide_in_width_40,
}

local evil_location = {
  'location',
  padding = { left = 2, right = 2 },
  cond = conditions.hide_in_width_40,
}

return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local evil_filename = require('lualine.components.filename'):extend()
    local highlight = require 'lualine.highlight'

    function evil_filename:init(options)
      evil_filename.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group({ gui = 'bold' }, 'filename_status_saved', self.options),
        modified = highlight.create_component_highlight_group({ fg = colors.yellow, gui = 'bold' }, 'filename_status_modified', self.options),
        readonly = highlight.create_component_highlight_group({ fg = colors.red, gui = 'bold' }, 'filename_status_modified', self.options),
      }
      if self.options.color == nil then
        self.options.color = ''
      end
      self.options.file_status = false
      self.options.path = 4
      self.options.cond = conditions.buffer_not_empty and conditions.hide_in_width_40
    end

    function evil_filename:update_status()
      local data = evil_filename.super.update_status(self)
      if vim.bo.readonly == true then
        data = highlight.component_format_highlight(self.status_colors.readonly) .. data
      else
        data = highlight.component_format_highlight(vim.bo.modified and self.status_colors.modified or self.status_colors.saved) .. data
      end
      return data
    end

    require('lualine').setup {
      options = {
        section_separators = '',
        component_separators = '',
        theme = evil_theme,
      },
      sections = {
        lualine_a = { evil_mode },
        lualine_b = { evil_filetype, evil_filename },
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
  end,
}
