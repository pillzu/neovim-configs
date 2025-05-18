return {
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    dependencies = {
      "folke/noice.nvim",
    },
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = '|',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {
          { 'mode', separator = { left = '' }, right_padding = 2 },
        },
        lualine_b = { 'filename', 'branch' },
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location', separator = { right = '' }, left_padding = 2 },
        },
        lualine_c = {
          {
            require("utils").windsurf_status,
            color = { fg = "#bf9e64" },
          },

        },
      },
      inactive_sections = {
      },
      tabline = {},
      extensions = {},

    },
  },
}
