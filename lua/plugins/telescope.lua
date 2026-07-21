return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    -- 0.1.x is frozen (2024) and still calls nvim-treesitter's removed
    -- `parsers.ft_to_lang`, which crashes previewers on Nvim 0.12 + treesitter
    -- `main`. Master uses vim.treesitter.language.get_lang / vim.treesitter.start.
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'junegunn/fzf', build = './install --bin' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },

    config = function()
      -- Prune heavy / irrelevant trees for fallback find/grep. Use ** so nested
      -- paths (and .git objects under --hidden) are excluded, not just one level.
      local exclude_globs = {
        '!**/.git/**',
        '!**/submodules/**',
        '!**/target/**',
        '!**/node_modules/**',
        '!**/bazel-*/**',
        '!**/.venv/**',
        '!**/vendor/**',
      }

      local vimgrep_args = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
        '--glob',
        '!**/.git/**',
      }
      for _, g in ipairs(exclude_globs) do
        vim.list_extend(vimgrep_args, { '--glob', g })
      end

      local find_command = { 'rg', '--files', '--hidden' }
      for _, g in ipairs(exclude_globs) do
        vim.list_extend(find_command, { '--glob', g })
      end

      require('telescope').setup {
        pickers = {
          find_files = {
            find_command = find_command,
          },
        },
        defaults = {
          vimgrep_arguments = vimgrep_args,
          -- Use Neovim's built-in TS highlighter in previews (works on 0.12).
          preview = {
            treesitter = true,
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-t>'] = require('trouble.sources.telescope').open,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')

      -- Buffers / oldfiles / help / diagnostics / git — not owned by fff.
      vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles,
        { desc = '[F]ind recently [o]pened files', silent = true })
      vim.keymap.set('n', '<leader><leader>', require('telescope.builtin').buffers,
        { desc = '[F]ind existing buffers', silent = true })
      vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers,
        { desc = '[F]ind [B]uffers', silent = true })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status,
        { desc = 'View [G]it [S]tatus', silent = true })
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files,
        { desc = 'Search [G]it [F]iles', silent = true })
      -- <leader>ff / <leader>fg owned by fff (plugins/fff.lua).
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags,
        { desc = '[F]ind [H]elp', silent = true })
      vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics,
        { desc = '[F]ind [D]iagnostics', silent = true })
    end
  },
}
