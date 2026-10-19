vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/j-hui/fidget.nvim',
}

require('fidget').setup {} -- LSP progress messages

local servers = {
  gleam = {},
  gopls = {},
  marksman = {},
  ruff = {},
  rust_analyzer = {},
  taplo = {},
  tinymist = {
    settings = {
      exportPdf = 'onType',
      outputPath = '$root/target/$dir/$name',
    },
  },
  yamlls = {},
  zls = {},
  lua_ls = {
    -- Make lua_ls aware of the Neovim runtime when editing this config
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
      })
    end,
    settings = { Lua = {} },
  },
}

-- Servers that mason can't install (install them yourself)
local not_in_mason = { gleam = true }

local ensure_installed = vim.tbl_filter(function(server) return not not_in_mason[server] end, vim.tbl_keys(servers))
vim.list_extend(ensure_installed, {
  -- formatters (conform)
  'stylua',
  'goimports',
  'prettierd',
  'shfmt',
  'yamlfmt',
  -- linters (nvim-lint)
  'golangci-lint',
  'markdownlint-cli2',
  'shellcheck',
  'yamllint',
})

require('mason').setup {}
require('mason-lspconfig').setup { automatic_enable = false }
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- grn, gra, grr, gri, grt, gO and K are Neovim defaults; see :help lsp-defaults
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local buf = event.buf
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { buf = buf, desc = 'LSP: [G]oto [D]eclaration' })

    if client:supports_method('textDocument/inlayHint', buf) then
      vim.keymap.set(
        'n',
        '<leader>th',
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }) end,
        { buf = buf, desc = 'LSP: [T]oggle Inlay [H]ints' }
      )
    end

    -- Highlight references of the word under the cursor
    if client:supports_method('textDocument/documentHighlight', buf) then
      local group = vim.api.nvim_create_augroup('lsp-highlight-' .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = buf, group = group, callback = vim.lsp.buf.document_highlight })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = buf, group = group, callback = vim.lsp.buf.clear_references })
      vim.api.nvim_create_autocmd('LspDetach', {
        buffer = buf,
        group = group,
        callback = function()
          vim.lsp.buf.clear_references()
          vim.api.nvim_del_augroup_by_id(group)
        end,
      })
    end
  end,
})
