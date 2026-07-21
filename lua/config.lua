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

  prosemd_lsp = {},
  markdown_oxide = {},
  harper_ls = {},

  -- python
  pylsp = {},

  stylua = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim', 'require' },
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
-- yaml/toml/json/bash/markdown: no LSP fallback for most of these, so TS is the highlighter.
M.ts_ensure_installed = {
  'bash',
  'c',
  'cpp',
  'go',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return M
