return {
  {
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require 'null-ls'
      local builtins = require('null-ls').builtins
      null_ls.setup {
        debug = true,
        sources = {
          builtins.diagnostics.staticcheck,
          builtins.diagnostics.markdownlint,
          builtins.diagnostics.markdownlint_cli2,
          builtins.formatting.markdownlint,
          builtins.formatting.prettierd,
        }
      }
    end,
  },
}
