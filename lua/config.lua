local M = {}
-- servers installed by mason and mason lsp config
M.mason_servers = {
  tsserver = {
    filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx', 'svelte' },
  },
  svelte = {},
  html = { filetypes = { 'html', 'twig', 'hbs' } },
  cssls = {},
  stylelint_lsp = {},
  eslint = {},
  tailwindcss = {},
  vtsls = {},

  docker_compose_language_service = {},
  dockerls = {},

  prismals = {},

  golangci_lint_ls = {},
  gopls = {},

  pyright = {},
  pylsp = {},

  bufls = {},
  bashls = {},

  clangd = {},
  lua_ls = {
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
          [vim.fn.stdpath 'data' .. '/lazy/ui/nvchad_types'] = true,
          [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

-- Tree-sitter-ensure-installed configuration
M.ts_ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' }


M.dashboard = function()
  local status_ok, alpha = pcall(require, "alpha")
  if not status_ok then
    return
  end

  local dashboard = require("alpha.themes.dashboard")
  dashboard.section.header.val = {
    [[░░░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░░░░░░░░░░]],
    [[░░░░░▄▄▄▄█▀▀▀░░░░░░░░░░░░▀▀██░░░░░░░░░░░░░░░]],
    [[░░▄███▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▄▄▄░░░░░░░░░░░]],
    [[▄▀▀░█░░░░▀█▄▀▄▀██████░▀█▄▀▄▀████▀░░░░░░░░░░░]],
    [[█░░░█░░░░░░▀█▄█▄███▀░░░░▀▀▀▀▀▀▀░▀▀▄░░░░░░░░░]],
    [[█░░░█░▄▄▄░░░░░░░░░░░░░░░░░░░░░▀▀░░░█░░░░░░░░]],
    [[█░░░▀█░░█░░░░▄░░░░▄░░░░░▀███▀░░░░░░░█░░░░░░░]],
    [[█░░░░█░░▀▄░░░░░░▄░░░░░░░░░█░░░░░░░░█▀▄░░░░░░]],
    [[░▀▄▄▀░░░░░▀▀▄▄▄░░░░░░░▄▄▄▀░▀▄▄▄▄▄▀▀░░█░░░░░░]],
    [[░█▄░░░░░░░░░░░░▀▀▀▀▀▀▀░░░░░░░░░░░░░░█░░░░░░░]],
    [[░░█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▄██░░░░░░░░]],
    [[░░▀█▄░░░░░░░░░░░░░░░░░░░░░░░░░▄▀▀░░░▀█░░░░░░]],
    [[█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█]],
    [[█░░█▀▄ █▀▀ █▀█ █░░░░█░▄░█ █ ▀█▀ █░█░░█ ▀█▀░█]],
    [[█░░█░█ █▀▀ █▀█ █░░░░▀▄▀▄▀ █ ░█░ █▀█░░█ ░█░░█]],
    [[█░░▀▀░ ▀▀▀ ▀░▀ ▀▀▀░░░▀░▀░ ▀ ░▀░ ▀░▀░░▀ ░▀░░█]],
    [[▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀]]
  }

  dashboard.section.buttons.val = {
    dashboard.button("f", "🔍  Find file", ":Telescope find_files <CR>"),
    dashboard.button("e", "📂  New file", ":ene <BAR> startinsert <CR>"),
    dashboard.button("r", "⏳  Recently used files", ":Telescope oldfiles <CR>"),
    dashboard.button("q", "❌  Quit Neovim", ":qa<CR>"),
  }

  local function footer()
    return "less go"
  end

  dashboard.section.footer.val = footer()
  dashboard.section.footer.val = require('alpha.fortune')

  dashboard.section.footer.opts.hl = "Type"
  dashboard.section.header.opts.hl = "Include"
  dashboard.section.buttons.opts.hl = "Keyword"

  dashboard.opts.opts.noautocmd = true
  alpha.setup(dashboard.opts)
end


return M
