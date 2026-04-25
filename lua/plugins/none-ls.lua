return {
  {
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require 'null-ls'
      local builtins = require('null-ls').builtins
      null_ls.setup {
        debug = false,
        sources = {
          builtins.diagnostics.staticcheck,
          builtins.diagnostics.markdownlint,
        },
      }
    end,
  },
}
