local M = {}
-- servers installed by mason and mason lsp config
M.mason_servers = {
  -- docker
  docker_compose_language_service = {},
  dockerls = {},

  -- go
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
      }
    }
  },

  bashls = {},

  puppet = {},
  prosemd_lsp = {},
  markdown_oxide = {},
  harper_ls = {},

  -- python
  pylsp = {},

  stylua = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        telemetry = { enable = false },
        workspace = {
          checkThirdParty = false,
          library = {
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
            [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = 'tab',
          },
        },
      },
    },
  },
}

-- Tree-sitter-ensure-installed configuration
M.ts_ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' }

return M
