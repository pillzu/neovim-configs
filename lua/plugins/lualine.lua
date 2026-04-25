return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { "folke/noice.nvim" },
    opts = {
      options = {
        theme = 'rose-pine',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          { 'mode', fmt = string.lower },   -- calm lowercase: normal / insert / visual
        },
        lualine_b = {
          'branch',
          {
            function()
              local bufs = vim.fn.getbufinfo({ buflisted = 1 })
              local cur = vim.fn.bufnr('%')
              for i, b in ipairs(bufs) do
                if b.bufnr == cur then return i .. '/' .. #bufs end
              end
              return '1/1'
            end,
            icon = '󰓩',
          },
        },
        lualine_c = {
          {
            'filename',
            path = 0,
            file_status = true,          -- shows [+] when modified, [-] when readonly
            shorting_target = 40,
          },
          {
            require("noice").api.status.mode.get,
            cond = require("noice").api.status.mode.has,
          },
        },
        lualine_x = { 'filetype' },
        lualine_y = {},
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_c = { { 'filename', path = 0 } },
        lualine_z = { 'location' },
      },
      tabline = {},
      extensions = {},
    },
  },
}
