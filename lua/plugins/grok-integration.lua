-- Grok CLI Integration
-- This plugin initializes all grok-related functionality:
-- 1. Hot-reload: Auto-reload files when grok edits them
-- 2. Yank with paths: Copy code with file paths for pasting into grok
-- 3. Directory watching: Efficient filesystem monitoring

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>y", group = "yank (grok)" },
        { "<leader>d", group = "diffview" },
        -- <leader>g group is owned by lua/plugins/groktmux.lua (tmux integration)
      },
    },
  },
  {
    -- This is a virtual plugin that loads our custom grok modules
    dir = vim.fn.stdpath('config') .. '/lua/custom',
    name = 'grok-integration',
    lazy = false,  -- Load immediately
    priority = 100,  -- Load early
    config = function()
      -- Setup hotreload (includes directory watcher)
      local hotreload_ok, hotreload = pcall(require, 'custom.hotreload')
      if hotreload_ok then
        hotreload.setup()
      end

      -- Setup yank with paths
      local yank_ok, yank = pcall(require, 'custom.yank')
      if yank_ok then
        yank.setup()
      end
    end,
  },
}
