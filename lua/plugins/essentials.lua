return {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- tmux <-> vim navigation
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require 'nvim-tmux-navigation'.setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
          last_active = "<C-\\>",
          next = "<C-Space>",
        }
      }
    end
  },

  -- maximize and restore current window
  'szw/vim-maximizer',

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Additional lua configuration, makes nvim stuff amazing!
  { 'folke/neodev.nvim',    opts = {} },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },

    config = function()
      local function my_on_attach(bufnr)
        local api = require 'nvim-tree.api'
        api.config.mappings.default_on_attach(bufnr)
      end

      local gwidth = vim.api.nvim_list_uis()[1].width
      local gheight = vim.api.nvim_list_uis()[1].height
      local height = 30
      local width = 80

      require('nvim-tree').setup {
        filters = {
          dotfiles = false,
          exclude = { vim.fn.stdpath 'config' .. '/lua/custom' },
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
          float = {
            enable = true,
            open_win_config = {
              relative = "editor",
              border = "rounded",
              width = width,
              height = height,
              row = (gheight - height) * 0.4,
              col = (gwidth - width) * 0.5,
            }
          }
        },
        git = {
          enable = true,
          ignore = true,
          disable_for_dirs = {
            "~/workspace/source/"
          }
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
          highlight_git = true,
          highlight_opened_files = 'none',

          indent_markers = {
            enable = false,
          },

          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },

            glyphs = {
              default = '󰈚',
              symlink = '',
              folder = {
                default = '',
                empty = '',
                empty_open = '',
                open = '',
                symlink = '',
                symlink_open = '',
                arrow_open = '',
                arrow_closed = '',
              },
              git = {
                unstaged = '✗',
                staged = '✓',
                unmerged = '',
                renamed = '➜',
                untracked = '★',
                deleted = '',
                ignored = '◌',
              },
            },
          },
        },
        sort_by = 'case_sensitive',
        on_attach = my_on_attach,
      }
      vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", { desc = "nvim-tree: Toggle", silent = true })
      vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", { desc = "nvim-tree: Toggle", silent = true })
    end,
  },
  {
    -- For auto indenting on creating a new tag
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    -- Get buffers
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local bufferline = require 'bufferline'
      bufferline.setup {
        options = {
          style_preset = bufferline.style_preset.slant, -- or bufferline.style_preset.minimal,
          themable = true,
          diagnostics = "nvim_lsp",
          -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
          --   local icon = level:match("error") and " " or " "
          --   return " " .. icon .. count
          -- end,
          color_icons = true, -- whether or not to add the filetype icon highlights
          show_close_icon = false
        },
        highlights = require("catppuccin.groups.integrations.bufferline").get(),
      }
    end,
  },
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require("colorizer").setup {
        user_default_options = {
          css = true,                                     -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          tailwind = true,                                -- Enable tailwind colors
          -- parsers can contain values used in |user_default_options|
          sass = { enable = true, parsers = { "css" }, }, -- Enable sass colors
          virtualtext = "■",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = true
        },
      }
    end
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  }
}
