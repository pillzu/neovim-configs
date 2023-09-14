local utils = require('utils')

return {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',


  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      char = '┊',
      show_trailing_blankline_indent = true,
    },
  },

  {
    "https://github.com/windwp/nvim-ts-autotag",
    opts = {
      autotag = {
        enable = true,
      }
    }
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },

    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true
          }
        end
        api.config.mappings.default_on_attach(bufnr)
      end

      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
          exclude = { vim.fn.stdpath "config" .. "/lua/custom" },
        },
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        hijack_unnamed_buffer_when_opening = false,
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          adaptive_size = false,
          side = "left",
          width = 30,
          preserve_window_proportions = true,
        },
        git = {
          enable = false,
          ignore = true,
        },
        filesystem_watchers = {
          enable = true,
        },
        actions = {
          open_file = {
            resize_window = true,
          },
        },
        renderer = {
          root_folder_label = false,
          highlight_git = false,
          highlight_opened_files = "none",

          indent_markers = {
            enable = false,
          },

          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = false,
            },

            glyphs = {
              default = "󰈚",
              symlink = "",
              folder = {
                default = "",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
                symlink_open = "",
                arrow_open = "",
                arrow_closed = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        sort_by = "case_sensitive",
        -- view = {
        --
        --   width = 30,
        -- },
        -- renderer = {
        --   group_empty = true,
        -- },
        -- filters = {
        --   dotfiles = true,
        -- },
        on_attach = my_on_attach
      })
    end
  },
  {
    -- For adding () around words
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    -- For auto indenting on creating a new tag
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup {
        style_preset = bufferline.style_preset.padded_slant, -- or bufferline.style_preset.minimal,

      }
    end
  },
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
}
