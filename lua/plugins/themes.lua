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
    lazy = true,
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
