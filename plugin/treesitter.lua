vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }

local ts = require 'nvim-treesitter'
ts.install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(lang) then return end
  vim.treesitter.start(buf, lang)
  if vim.treesitter.query.get(lang, 'indents') then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

-- Start treesitter for every filetype, installing missing parsers on demand
local available = ts.get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end
    if vim.tbl_contains(available, lang) and not vim.tbl_contains(ts.get_installed 'parsers', lang) then
      ts.install(lang):await(function() attach(args.buf, lang) end)
    else
      attach(args.buf, lang)
    end
  end,
})
