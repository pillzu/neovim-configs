return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    opts = {
      rocks = { "magick" }
    },
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
          ["core.pivot"] = {},
          ["core.esupports.metagen"] = {
            config = {
              type = "empty"
            }
          },
          ["core.summary"] = {
            config = {
              strategy = "by_path"
            }
          },
          ["core.promo"] = {},
          ["core.itero"] = {},
          ["core.journal"] = {
          },
          ["core.concealer"] = {
            config = {
              folds = false,
              icon_preset = "diamond",
            }
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                misc = "~/misc",
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
        },
      }
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.norg" },
        callback = function()
          vim.opt_local.conceallevel = 3
        end
      })
    end,
  }
}
