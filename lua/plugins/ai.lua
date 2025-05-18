return {
    {
        "Exafunction/windsurf.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup({
                virtual_text = {
                    enabled = true,
                },
            })
            require('codeium.virtual_text').set_statusbar_refresh(function()
                require('lualine').refresh()
            end)
        end
    },
}
