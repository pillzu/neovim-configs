local M = {}
-- servers installed by mason and mason lsp config
M.mason_servers = {
  docker_compose_language_service = {},
  dockerls = {},

  pyright = {},
  pylsp = {},

  bashls = {},

  puppet = {},
  prosemd_lsp = {},
  markdown_oxide = {},
  harper_ls = {},

  jdtls = {

  },

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

M.dashboard = function()
  local status_ok, alpha = pcall(require, 'alpha')
  if not status_ok then
    return
  end

  local dashboard = require 'alpha.themes.dashboard'

  dashboard.section.header.val = {
    [[          _____                    _____                    _____            _____            _____          ]],
    [[         /\    \                  /\    \                  /\    \          /\    \          /\    \         ]],
    [[        /::\    \                /::\    \                /::\____\        /::\____\        /::\____\        ]],
    [[       /::::\    \               \:::\    \              /:::/    /       /:::/    /       /:::/    /        ]],
    [[      /::::::\    \               \:::\    \            /:::/    /       /:::/    /       /:::/    /         ]],
    [[     /:::/\:::\    \               \:::\    \          /:::/    /       /:::/    /       /:::/    /          ]],
    [[    /:::/__\:::\    \               \:::\    \        /:::/    /       /:::/    /       /:::/    /           ]],
    [[   /::::\   \:::\    \              /::::\    \      /:::/    /       /:::/    /       /:::/    /            ]],
    [[  /::::::\   \:::\    \    ____    /::::::\    \    /:::/    /       /:::/    /       /:::/    /      _____  ]],
    [[ /:::/\:::\   \:::\____\  /\   \  /:::/\:::\    \  /:::/    /       /:::/    /       /:::/____/      /\    \ ]],
    [[/:::/  \:::\   \:::|    |/::\   \/:::/  \:::\____\/:::/____/       /:::/____/       |:::|    /      /::\____\]],
    [[\::/    \:::\  /:::|____|\:::\  /:::/    \::/    /\:::\    \       \:::\    \       |:::|____\     /:::/    /]],
    [[ \/_____/\:::\/:::/    /  \:::\/:::/    / \/____/  \:::\    \       \:::\    \       \:::\    \   /:::/    / ]],
    [[          \::::::/    /    \::::::/    /            \:::\    \       \:::\    \       \:::\    \ /:::/    /  ]],
    [[           \::::/    /      \::::/____/              \:::\    \       \:::\    \       \:::\    /:::/    /   ]],
    [[            \::/____/        \:::\    \               \:::\    \       \:::\    \       \:::\__/:::/    /    ]],
    [[             ~~               \:::\    \               \:::\    \       \:::\    \       \::::::::/    /     ]],
    [[                               \:::\    \               \:::\    \       \:::\    \       \::::::/    /      ]],
    [[                                \:::\____\               \:::\____\       \:::\____\       \::::/    /       ]],
    [[                                 \::/    /                \::/    /        \::/    /        \::/____/        ]],
    [[                                  \/____/                  \/____/          \/____/          ~~              ]],
  }

  dashboard.section.buttons.val = {
    dashboard.button('f', '🔍  Find file', ':Telescope find_files <CR>'),
    dashboard.button('e', '📂  New file', ':ene <BAR> startinsert <CR>'),
    dashboard.button('r', '⏳  Recently used files', ':Telescope oldfiles <CR>'),
    dashboard.button('q', '❌  Quit Neovim', ':qa<CR>'),
  }

  dashboard.section.footer.val = "Never think you ain't gonna do it :)"

  dashboard.section.footer.opts.hl = 'Type'
  dashboard.section.header.opts.hl = 'Include'
  dashboard.section.buttons.opts.hl = 'Keyword'

  dashboard.opts.opts.noautocmd = true
  alpha.setup(dashboard.opts)
end

return M
