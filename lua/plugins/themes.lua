return {
  {
    "rose-pine/neovim",
    opts = {
      styles = {
        transparency = true,
      }
    },
    name = "rose-pine"
  },
  {
    'Mofiqul/dracula.nvim',
    opts = {
      transparent_bg = true,
    },
    config = function(_, opts)
      require("dracula").setup(opts)

      -- vim.cmd.colorscheme "dracula"
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        flavour = "mocha",             -- latte, frappe, macchiato, mocha
        transparent_background = true, -- disables setting the background color.
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          alpha = true,
          indent_blankline = {
            enabled = true,
            scope_color = "mocha",
            colored_indent_levels = true,
          },
        }
      }

      vim.cmd.colorscheme "catppuccin"
    end
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_telescope = true,
        terminal_colors = true,
      })
      -- vim.cmd("colorscheme cyberdream") -- set the colorscheme
    end,
  }
}
