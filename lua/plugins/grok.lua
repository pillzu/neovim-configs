-- Grok integration: hotreload + feed context into a Grok tmux pane.

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>g', group = 'grok' },
        {
          '<leader>gg',
          function()
            local mode = vim.fn.mode()
            local visual = mode == 'v' or mode == 'V' or mode == '\22'
            require('groktmux.feed').dispatch({ visual = visual })
          end,
          desc = 'Grok: ask with context',
          mode = { 'n', 'v' },
        },
        { '<leader>gP', '<cmd>GrokAttachPane<cr>', desc = 'Grok: attach tmux pane' },
      },
    },
  },

  {
    dir = vim.fn.stdpath('config') .. '/lua/groktmux',
    name = 'grok',
    lazy = false,
    priority = 100,
    config = function()
      local hr_ok, hotreload = pcall(require, 'hotreload')
      if hr_ok then
        hotreload.setup()
      end

      local ok, groktmux = pcall(require, 'groktmux')
      if ok then
        groktmux.setup()
      else
        vim.notify('[plugins/grok] failed to load: ' .. tostring(groktmux), vim.log.levels.ERROR)
      end
    end,
  },
}
