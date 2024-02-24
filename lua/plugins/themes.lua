return {
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
          fidget = true,
        }
      }
    end
  },
}
