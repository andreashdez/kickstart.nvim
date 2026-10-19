vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }

local gitsigns = require 'gitsigns'
gitsigns.setup {
  on_attach = function(buf)
    local map = function(mode, keys, func, desc) vim.keymap.set(mode, keys, func, { buf = buf, desc = desc }) end
    local selection = function() return { vim.fn.line '.', vim.fn.line 'v' } end

    -- Navigation (falls back to the built-in ]c/[c in diff mode)
    map('n', ']c', function()
      if vim.wo.diff then return vim.cmd.normal { ']c', bang = true } end
      gitsigns.nav_hunk 'next'
    end, 'Jump to next git [c]hange')
    map('n', '[c', function()
      if vim.wo.diff then return vim.cmd.normal { '[c', bang = true } end
      gitsigns.nav_hunk 'prev'
    end, 'Jump to previous git [c]hange')

    -- Actions
    map('v', '<leader>hs', function() gitsigns.stage_hunk(selection()) end, 'git [s]tage hunk')
    map('v', '<leader>hr', function() gitsigns.reset_hunk(selection()) end, 'git [r]eset hunk')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'git [s]tage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'git [r]eset hunk')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'git [S]tage buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'git [R]eset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'git [p]review hunk')
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'git preview hunk [i]nline')
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, 'git [b]lame line')
    map('n', '<leader>hd', gitsigns.diffthis, 'git [d]iff against index')
    map('n', '<leader>hD', function() gitsigns.diffthis '~' end, 'git [D]iff against last commit')
    map('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, 'git hunk [Q]uickfix list (all files in repo)')
    map('n', '<leader>hq', gitsigns.setqflist, 'git hunk [q]uickfix list (all changes in this file)')

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git show [b]lame line')
    map('n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle git intra-line [w]ord diff')

    -- Text object
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'text object [i]nside [h]unk')
  end,
}
