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
  require 'plugins.autoformat',
  require 'plugins.debug',
  require 'plugins.themes',
  require 'plugins.telescope',
  require 'plugins.mason',
  require 'plugins.git',
  require 'plugins.nvim-cmp',
  require 'plugins.treesitter',
  require 'plugins.lualine',
  require 'plugins.comment',
  require 'plugins.essentials',
})
