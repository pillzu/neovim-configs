-- Loader for groktmux — Grok <-> Neovim via tmux + post-disk review.
-- Virtual plugin (same pattern as grok-integration.lua): loads the pure-Lua
-- lua/groktmux/* modules early and registers commands + which-key entries.

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>g', group = 'grok (tmux)' },
        { '<leader>gg', '<cmd>GrokAsk<cr>', desc = 'Grok: ask (no review)', mode = { 'n', 'v' } },
        { '<leader>ge', '<cmd>GrokEdit<cr>', desc = 'Grok: edit (arms review)', mode = { 'n', 'v' } },
        { '<leader>gG', '<cmd>GrokEditDiff<cr>', desc = 'Grok: edit + diff (arms review)', mode = { 'n', 'v' } },
        { '<leader>gr', '<cmd>GrokReview<cr>', desc = 'Grok: review changeset' },
        { '<leader>gx', '<cmd>GrokReviewClear<cr>', desc = 'Grok: clear review' },
        { '<leader>gP', '<cmd>GrokAttachPane<cr>', desc = 'Grok: attach tmux pane' },
      },
    },
  },

  {
    dir = vim.fn.stdpath('config') .. '/lua/groktmux',
    name = 'groktmux',
    lazy = false,
    priority = 95,
    config = function()
      local ok, groktmux = pcall(require, 'groktmux')
      if ok then
        groktmux.setup()
      else
        vim.notify('[plugins/groktmux] failed to load: ' .. tostring(groktmux), vim.log.levels.ERROR)
      end
    end,
  },
}
