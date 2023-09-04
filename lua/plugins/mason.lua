return {
  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      { 'hrsh7th/cmp-nvim-lsp' },
      {
        'williamboman/mason-lspconfig.nvim',
        config = function()
          local utils = require('utils')
          local mason_lspconfig = require 'mason-lspconfig'
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
          local servers = utils.servers
          mason_lspconfig.setup {
            ensure_installed = vim.tbl_keys(servers),
          }

          mason_lspconfig.setup_handlers {
            function(server_name)
              require('lspconfig')[server_name].setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                  require "lsp_signature".on_attach({
                    bind = true, -- This is mandatory, otherwise border config won't get registered.
                    handler_opts = {
                      border = "rounded"
                    }
                  }, bufnr)
                  utils.on_attach(client, bufnr)
                end,
                settings = servers[server_name],
                filetypes = (servers[server_name] or {}).filetypes,
              }
            end
          }
        end
      },

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      { 'folke/neodev.nvim', opts = {} },
    },
  },
}
