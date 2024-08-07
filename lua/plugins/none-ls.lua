return {
  {
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require 'null-ls'
      local builtins = require('null-ls').builtins
      null_ls.setup {
        sources = {
          builtins.diagnostics.codespell,
          builtins.formatting.rustywind,
        }
      }
    end,
  },
}
