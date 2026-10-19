vim.pack.add {
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-lint',
}

-- [[ Formatting ]]
require('conform').setup {
  notify_on_error = false,
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'goimports', 'gofmt' },
    rust = { 'rustfmt' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'yamlfmt', 'prettierd', 'prettier', stop_after_first = true },
    toml = { 'taplo' },
    zig = { 'zigfmt' },
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- [[ Linting ]]
local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  yaml = { 'yamllint' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  zsh = { 'shellcheck' },
  go = { 'golangcilint' },
  rust = { 'clippy' },
  zig = { 'zlint' },
}

-- These lint the whole project and are too slow to run on every BufEnter/InsertLeave
local on_save_only = { golangcilint = true, clippy = true, zlint = true }

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('lint', { clear = true }),
  callback = function(args)
    if not vim.bo.modifiable then return end
    local linters = vim.tbl_filter(function(name) return args.event == 'BufWritePost' or not on_save_only[name] end, lint.linters_by_ft[vim.bo.filetype] or {})
    lint.try_lint(linters)
  end,
})
