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

            -- Set up Mason and mason-lspconfig
            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = require('config').mason_ensure_installed,
                automatic_enable = true, -- Automatically enable installed servers
            })

            -- LSP attach autocommands for document highlighting
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach-format', { clear = true }),
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
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
