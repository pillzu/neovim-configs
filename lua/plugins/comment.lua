return {
  {
    'numToStr/Comment.nvim',
    init = function()
      vim.keymap.set('n', '<leader>/', require('Comment.api').toggle.linewise.current, { desc = 'Toggle Comment' })
      vim.keymap.set('v', '<leader>/', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = 'Toggle Comment' })
    end,
    config = function(_, opts)
      opts.mappings = {
        basic = false,
        extra = false,
      }
      require('Comment').setup(opts)
    end,
  },
}
