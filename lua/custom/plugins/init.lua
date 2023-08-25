-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts) require 'lsp_signature'.setup(opts) end
	},
	{
		"https://github.com/windwp/nvim-ts-autotag",
		config = function()
			require 'nvim-treesitter.configs'.setup {
				autotag = {
					enable = true,
				}
			}
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},

		config = function()
			local function my_on_attach(bufnr)
				local api = require "nvim-tree.api"
				local function opts(desc)
					return {
						desc = "nvim-tree: " .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true
					}
				end
				api.config.mappings.default_on_attach(bufnr)
			end

			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = {

					width = 30,
				},
				renderer = {
					group_empty = true,
				},
				filters = {

					dotfiles = true,
				},
				on_attach = my_on_attach
			})
		end
	},
	{
		-- For adding () around words
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end
	},
	{
		-- For auto indenting on creating a new tag
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {}
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {}
	},
	{
		'romgrk/barbar.nvim',
		dependencies = {
			'lewis6991/gitsigns.nvim',  -- OPTIONAL: for git status
			'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
		},
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {
			auto_hide = true
		},
		version = '^1.0.0', -- optional: only update when a new 1.x version is released
	},
}
