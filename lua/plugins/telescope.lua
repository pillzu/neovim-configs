return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        -- telescope file browser
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        lazy = false,
      },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- make sure you have `make`
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },

    config = function()
      local telescope_config = require("telescope.config")
      -- Check if vimgrep_arguments is not nil before unpacking
      local vimgrep_arguments = telescope_config.values.vimgrep_arguments or {}

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")

      require('telescope').setup {
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
          }
        },
        defaults = {
          vimgrep_arguments = vimgrep_arguments,
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
        extensions = {
          -- file_browser = {
          --   theme = "dropdown",
          --   hijack_netrw = true,
          -- },
        }
      }

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles,
        { desc = '[F]ind recently [o]pened files', silent = true })
      vim.keymap.set('n', '<leader><leader>', require('telescope.builtin').buffers,
        { desc = '[ ] Find existing buffers', silent = true })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status,
        { desc = 'View [G]it [S]tatus', silent = true })
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files,
        { desc = 'Search [G]it [F]iles', silent = true })
      vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files,
        { desc = '[F]ind [F]iles', silent = true })
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[F]ind [H]elp', silent = true })
      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep,
        { desc = '[F]ind by [G]rep', silent = true })
      vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics,
        { desc = '[F]ind [D]iagnostics', silent = true })
      vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", { desc = "nvim-tree: Toggle", silent = true })
    end
  },
}
