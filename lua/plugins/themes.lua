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
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      saturation = 0.0
    }
  },
  {
    'Mofiqul/dracula.nvim',
    opts = {
      transparent_bg = true,
    }
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        flavour = "macchiato",         -- latte, frappe, macchiato, mocha
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
    end
  },
}
