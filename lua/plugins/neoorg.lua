return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              folds = false
            }
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
        },
      }

      -- vim.api.nvim_create_augroup('NeorgConcealer', { clear = true })
      -- vim.api.nvim_create_autocmd("BufEnter", {
      --   group = "NeorgConcealer",
      --   pattern = "*.neorg",
      --   command = "set conceallevel=3"
      -- })
    end,
  }
}
