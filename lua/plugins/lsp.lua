return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'mason-org/mason.nvim', config = true }, -- Eager loading recommended
            'mason-org/mason-lspconfig.nvim',
            {
                'j-hui/fidget.nvim',
                opts = {
                    notification = {
                        window = {
                            winblend = 0,
                        },
                    },
                },
            },
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            -- Set up global LSP capabilities with nvim-cmp integration
            local capabilities = vim.tbl_deep_extend(
                'force',
                vim.lsp.protocol.make_client_capabilities(),
                require('cmp_nvim_lsp').default_capabilities()
            )

            -- Apply global defaults for all LSP servers
            vim.lsp.config('*', {
                capabilities = capabilities,
                on_attach = require('utils').on_attach,
            })

            -- Set up Mason and mason-lspconfig.
            -- config.mason_servers is a table keyed by server name with per-server
            -- opts (settings, etc.). Build the ensure_installed list from its keys
            -- and apply each server's opts via vim.lsp.config so the settings
            -- (gopls gofumpt/staticcheck, lua_ls, ...) actually take effect.
            local servers = require('config').mason_servers
            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = true, -- Automatically enable installed servers
            })
            for name, opts in pairs(servers) do
                if type(opts) == 'table' and next(opts) ~= nil then
                    vim.lsp.config(name, opts)
                end
            end

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach-format', { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd('CursorHold', {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd('CursorMoved', {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
