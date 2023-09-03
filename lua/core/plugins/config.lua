local M = {}

M.servers = {
  tsserver = {
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  },
  html = { filetypes = { 'html', 'twig', 'hbs' } },

  bufls = {},
  clangd = {},
  cssls = {},
  docker_compose_language_service = {},
  eslint = {},
  golangci_lint_ls = {},
  gopls = {},
  prismals = {},
  pyright = {},
  pylsp = {},
  rust_analyzer = {},
  stylelint_lsp = {},
  svelte = {},


  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

return M
