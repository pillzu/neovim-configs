return {
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            require('utils').on_attach(client, bufnr)

            -- Re-apply our Telescope mappings last so rustaceanvim doesn't override them
            local tb = require('telescope.builtin')
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set('n', 'gd',  function() tb.lsp_definitions({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [D]efinition' }))
            vim.keymap.set('n', 'gD',  function() tb.lsp_type_definitions({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto Type [D]efinition' }))
            vim.keymap.set('n', 'gr',  function() tb.lsp_references({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [R]eferences' }))
            vim.keymap.set('n', 'gi',  function() tb.lsp_implementations({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [I]mplementation' }))
            vim.keymap.set('n', 'gs',  function() tb.lsp_document_symbols() end, vim.tbl_extend('force', opts, { desc = '[D]ocument [S]ymbols' }))
            vim.keymap.set('n', 'gws', function() tb.lsp_dynamic_workspace_symbols() end, vim.tbl_extend('force', opts, { desc = '[W]orkspace [S]ymbols' }))
          end,
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              check = { command = "clippy" },
              lens = { enable = true },
            },
          },
        },
        tools = {
          which_key = false,
          hover_actions = { enable = false },
        },
      }
    end,
  },
}
