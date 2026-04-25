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

  -- Modern Lua LSP enhancements (replaces deprecated neodev)
  { 'folke/lazydev.nvim', opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@diagnostic disable-next-line: undefined-doc-name
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

      vim.keymap.set('n', '<c-n>', "<cmd>NvimTreeToggle<CR>", { desc = "nvim-tree: Toggle", silent = true })
    end,
  },
  {
    -- For auto indenting on creating a new tag
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        css = true,
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
        always_update = true,
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      vim.g.afmt_enabled = true
      vim.api.nvim_create_user_command('Afmt', function()
        vim.g.afmt_enabled = not vim.g.afmt_enabled
        print("Autoformatting is " .. (vim.g.afmt_enabled and "enabled" or "disabled"))
      end, { nargs = 0 })

      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'black', 'isort' },
          rust = { 'rustfmt' },
          go = { 'gofmt' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          svelte = { 'prettier' },
          markdown = { 'markdownlint' },
        },
        format_on_save = function(bufnr)
          if not vim.g.afmt_enabled then
            return
          end
          return {
            timeout_ms = 500,
            lsp_fallback = true,
          }
        end,
      }
    end,
  },
}
