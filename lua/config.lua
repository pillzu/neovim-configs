local M = {}
M.mason_ensure_installed = {
  'bashls',
  'docker_compose_language_service',
  'dockerls',
  'gopls',
  'lua_ls',
  'markdown_oxide',
  'prosemd_lsp',
  'puppet',
  'pylsp',
  'stylua',
  'tailwindcss',
}

-- Tree-sitter-ensure-installed configuration
M.ts_ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'rust' }

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

  dashboard.section.footer.val = 'Act, Adapt, Conquer!'

  dashboard.section.footer.opts.hl = 'Type'
  dashboard.section.header.opts.hl = 'Include'
  dashboard.section.buttons.opts.hl = 'Keyword'

  dashboard.opts.opts.noautocmd = true
  alpha.setup(dashboard.opts)
end

return M
