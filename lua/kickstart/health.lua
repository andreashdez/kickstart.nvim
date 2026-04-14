--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local uv = vim.uv or vim.loop

---@param exe string
---@return string|nil resolved_path
---@return string|nil path
---@return string|nil err
local resolve_executable = function(exe)
  local path = vim.fn.exepath(exe)
  if path == nil or path == '' then return nil end

  local resolved_path = uv.fs_realpath and uv.fs_realpath(path) or path
  if not resolved_path then return nil, path, 'broken' end

  return resolved_path, path
end

---@param exe string
---@param description string
---@return boolean
local check_executable = function(exe, description)
  local resolved_path, path, err = resolve_executable(exe)
  if resolved_path then
    vim.health.ok(string.format("Found %s executable: '%s' (%s)", description, exe, path))
    return true
  end

  if err == 'broken' then
    vim.health.warn(string.format("Found %s executable, but it is a broken link: '%s'", description, path))
    return false
  end

  vim.health.warn(string.format("Could not find %s executable: '%s'", description, exe))
  return false
end

---@param candidates string[]
---@param description string
---@return boolean
local check_any_executable = function(candidates, description)
  local broken_path = nil

  for _, exe in ipairs(candidates) do
    local resolved_path, path, err = resolve_executable(exe)
    if resolved_path then
      vim.health.ok(string.format("Found %s executable: '%s' (%s)", description, exe, path))
      return true
    end

    if err == 'broken' then broken_path = path end
  end

  if broken_path then
    vim.health.warn(string.format("Found %s executable, but it is a broken link: '%s'", description, broken_path))
    return false
  end

  vim.health.warn(string.format('Could not find %s executable. Tried: %s', description, table.concat(candidates, ', ')))
  return false
end

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.11') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local check_external_reqs = function()
  vim.health.start 'External dependencies'

  for _, tool in ipairs {
    { exe = 'git', description = 'git' },
    { exe = 'make', description = 'make' },
    { exe = 'unzip', description = 'unzip' },
    { exe = 'rg', description = 'ripgrep' },
    { exe = 'tree-sitter', description = 'tree-sitter CLI' },
    { exe = 'node', description = 'Node.js runtime' },
  } do
    check_executable(tool.exe, tool.description)
  end

  check_any_executable({ 'fd', 'fdfind' }, 'fd')
  check_any_executable({ 'cc', 'gcc', 'clang' }, 'C compiler')

  if vim.fn.has 'mac' == 1 then
    check_any_executable({ 'pbcopy' }, 'clipboard provider')
  elseif vim.fn.has 'win32' == 1 then
    check_any_executable({ 'win32yank', 'clip' }, 'clipboard provider')
  else
    check_any_executable({ 'wl-copy', 'xclip', 'xsel' }, 'clipboard provider')
  end

  vim.health.start 'Configured tools'
  vim.health.info 'These checks mirror language tools configured in this fork.'

  for _, tool in ipairs {
    { exe = 'stylua', description = 'Lua formatter (conform)' },
    { exe = 'markdownlint-cli2', description = 'Markdown linter (nvim-lint)' },
    { exe = 'shellcheck', description = 'Shell linter (nvim-lint)' },
    { exe = 'yamllint', description = 'YAML linter (nvim-lint)' },
    { exe = 'golangci-lint', description = 'Go linter (nvim-lint, save only)' },
    { exe = 'cargo', description = 'Rust linter runner (nvim-lint, save only)' },
    { exe = 'clippy-driver', description = 'Rust linter backend (nvim-lint, save only)' },
    { exe = 'zlint', description = 'Zig linter (nvim-lint, save only)' },
    { exe = 'lua-language-server', description = 'Lua LSP (lua_ls)' },
    { exe = 'gleam', description = 'Gleam LSP runner (gleam lsp)' },
    { exe = 'gopls', description = 'Go LSP (gopls)' },
    { exe = 'marksman', description = 'Markdown LSP (marksman)' },
    { exe = 'ruff', description = 'Python LSP (ruff)' },
    { exe = 'rust-analyzer', description = 'Rust LSP (rust_analyzer)' },
    { exe = 'taplo', description = 'TOML LSP (taplo)' },
    { exe = 'tinymist', description = 'Typst LSP (tinymist)' },
    { exe = 'yaml-language-server', description = 'YAML LSP (yamlls)' },
    { exe = 'zls', description = 'Zig LSP (zls)' },
  } do
    check_executable(tool.exe, tool.description)
  end

  return true
end

return {
  check = function()
    vim.health.start 'kickstart.nvim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
  end,
}
