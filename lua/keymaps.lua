-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('i', 'jk', '<ESC>')

-- Numbers
vim.keymap.set('n', '<leader>+', '<C-a>', { desc = "Increment Number" })
vim.keymap.set('n', '<leader>-', '<C-x>', { desc = "Descrement Number" })

-- split window
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = "[S]plit [V]ertically", silent = true })
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = "[S]plit [H]orizontally", silent = true })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = "[S]plit [E]qually", silent = true })
vim.keymap.set('n', '<leader>sx', ':close<CR>', { desc = "[S]plit [C]lose", silent = true })
vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", { desc = "[S]plit [M]aximize", silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- next,previous and close buffer
function ForceQuit()
  if vim.bo.modified then
    if vim.b.unsaved then
      vim.cmd('bd!')
      vim.b.unsaved = nil
    else
      vim.b.unsaved = true
      print("Buffer is modified, press <leader> x again to discard changes and quit")
    end
  else
    vim.cmd('bd!')
  end
end

vim.api.nvim_set_keymap('n', '<leader>x', ':lua ForceQuit()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Tab>', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bp<CR>', { noremap = true, silent = true })

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

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
