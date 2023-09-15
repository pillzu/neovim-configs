require 'options'
require 'keymaps'

-- install Lazy
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- theme
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'carbonfox'
    end,
  },
  -- -- dashboard
  -- {
  --   'glepnir/dashboard-nvim',
  --   event = 'VimEnter',
  --   config = function()
  --     local db = require('config').dashboard
  --     require('dashboard').setup({})
  --   end,
  --   dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  -- },

  {
    'goolord/alpha-nvim',
    config = function()
      require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
    end
  },

  -- Additional lua configuration, makes nvim stuff amazing!
  { 'folke/neodev.nvim', opts = {} },

  { import = 'plugins' }
})
