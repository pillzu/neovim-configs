-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('i', 'jk', '<ESC>')

-- Numbers
vim.keymap.set('n', '<leader>+', '<C-a>', { desc = 'Increment Number' })
vim.keymap.set('n', '<leader>-', '<C-x>', { desc = 'Descrement Number' })

-- split window
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = '[S]plit [V]ertically', silent = true })
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = '[S]plit [H]orizontally', silent = true })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = '[S]plit [E]qually', silent = true })
vim.keymap.set('n', '<leader>sx', ':close<CR>', { desc = '[S]plit [C]lose', silent = true })
vim.keymap.set('n', '<leader>sm', ':MaximizerToggle<CR>', { desc = '[S]plit [M]aximize', silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- next,previous and close buffer
function ForceQuit()
  if vim.bo.modified then
    if vim.b.unsaved then
      vim.cmd 'bd!'
      vim.b.unsaved = nil
    else
      vim.b.unsaved = true
      print 'Buffer is modified, press <leader> x again to discard changes and quit'
    end
  else
    vim.cmd 'bd!'
  end
end

vim.keymap.set('n', '<leader>x', ForceQuit, { desc = 'Close buffer (confirm if modified)' })
vim.keymap.set('n', '<Tab>', ':bn<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bp<CR>', { desc = 'Previous buffer' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Open current line / selection on GitHub (via fugitive + rhubarb's :GBrowse)
vim.keymap.set('n', '<leader>gh', '<cmd>GBrowse<cr>', { desc = 'Open line in [G]it[H]ub' })
vim.keymap.set('v', '<leader>gh', ':GBrowse<cr>', { desc = 'Open selection in [G]it[H]ub' })
-- Bang variant copies the URL to the clipboard instead of opening the browser
vim.keymap.set('n', '<leader>gH', '<cmd>GBrowse!<cr>', { desc = 'Copy [G]it[H]ub URL of line' })
vim.keymap.set('v', '<leader>gH', ":GBrowse!<cr>", { desc = 'Copy [G]it[H]ub URL of selection' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- LSP Diagnostics Options Setup (modern style)
vim.diagnostic.config {
  virtual_text = {
    prefix = "●",
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN]  = "󰀪",
      [vim.diagnostic.severity.INFO]  = "󰋽",
      [vim.diagnostic.severity.HINT]  = "󰌶",
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}
