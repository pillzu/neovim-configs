-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
local utils = require 'utils'

-- indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2

opt.cursorline = true

opt.background = "dark"

-- disable nvim information
opt.shortmess:append "sI"

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.relativenumber = true
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- FIX: Idk what's wrong but this don't work
-- Determine clipboard command based on availability
-- if utils.cmd_exists("xsel") then
--   vim.g.clipboard = {
--     name = "xsel",
--     copy = {
--       ["+"] = "xsel --nodetach -i -b",
--       ["*"] = "xsel --nodetach -i -p",
--     },
--     paste = {
--       ["+"] = "xsel -o -b",
--       ["*"] = "xsel -o -b",
--     },
--     cache_enabled = 1,
--   }
-- elseif utils.cmd_exists("wl-copy") then
--   vim.g.clipboard = {
--     name = "wl-clipboard",
--     copy = {
--       ["+"] = "wl-copy",
--       ["*"] = "wl-copy --primary",
--     },
--     paste = {
--       ["+"] = "wl-paste",
--       ["*"] = "wl-paste --primary",
--     },
--     cache_enabled = 1,
--   }
-- else
--   -- Set clipboard settings
--   -- vim.g.clipboard = 'unnamedplus'
--   vim.g.clipboard = "unnamed,unnamedplus"
-- end
vim.g.clipboard = "unnamed,unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- split
opt.splitright = true
opt.splitbelow = true

-- NOTE: Careful! Terminal must support this
vim.o.termguicolors = true

vim.cmd("colorscheme cyberdream") -- set the colorscheme

vim.g.foldmethod = "manual"
