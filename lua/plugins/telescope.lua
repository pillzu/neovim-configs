return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { "junegunn/fzf",                             build = "./install --bin" },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },

    config = function()
      -- Modern way to extend rg arguments for hidden files + gitignore
      local vimgrep_args = {
        "rg", "--color=never", "--no-heading", "--with-filename",
        "--line-number", "--column", "--smart-case", "--hidden", "--glob", "!**/.git/*"
      }

      require('telescope').setup {
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
          }
        },
        defaults = {
          vimgrep_arguments = vimgrep_args,
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-t>'] = require('trouble.sources.telescope').open,  -- Send results to Trouble (great for cycling all LSP results)
            },
          },
        },
        extensions = {
          -- file_browser = {
          --   theme = "dropdown",
          --   hijack_netrw = true,
          -- },
          fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          }
        }
      }

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles,
        { desc = '[F]ind recently [o]pened files', silent = true })
      vim.keymap.set('n', '<leader><leader>', require('telescope.builtin').buffers,
        { desc = '[F]ind existing buffers', silent = true })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status,
        { desc = 'View [G]it [S]tatus', silent = true })
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files,
        { desc = 'Search [G]it [F]iles', silent = true })
      vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files,
        { desc = '[F]ind [F]iles', silent = true })
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags,
        { desc = '[F]ind [H]elp', silent = true })
      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep,
        { desc = '[F]ind by [G]rep', silent = true })
      vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics,
        { desc = '[F]ind [D]iagnostics', silent = true })
    end
  },
}
