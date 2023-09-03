return {

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
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
      local vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
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
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
          },
        },
      }

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require("telescope").load_extension "file_browser")

      vim.api.nvim_set_keymap(
        "n",
        "<space>fb",
        ":Telescope file_browser<CR>",
        { noremap = true }
      )

      vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles,
        { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'View Git Status' })
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
      vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>fw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", { desc = "nvim-tree: Toggle" })
      vim.keymap.set('n', '<leader>l', ":NvimTreeFocus<CR>", { desc = "nvim-tree: Focus" })
      print('keymaps set')
    end
  },
}
