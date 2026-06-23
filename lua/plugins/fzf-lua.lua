-- fzf-lua — fast file + grep finder for large repos.
-- Shells out to the real fzf/rg binaries and streams results, so it stays fast at
-- repo sizes where Telescope's Lua-side sort/render stalls. Telescope is kept for
-- LSP/git/diagnostics pickers (see plugins/telescope.lua); fzf-lua owns <leader>ff
-- (files) and <leader>fg (live grep).

return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- Lazy-load on the keymaps below; `keys` triggers the load on first press.
    keys = {
      { '<leader>ff', function() require('fzf-lua').files() end, desc = '[F]ind [F]iles (fzf)' },
      { '<leader>fg', function() require('fzf-lua').live_grep() end, desc = '[F]ind by [G]rep (fzf)' },
      { '<leader>fb', function() require('fzf-lua').buffers() end, desc = '[F]ind [B]uffers (fzf)' },
      { '<leader>fr', function() require('fzf-lua').resume() end, desc = '[F]ind [R]esume last (fzf)' },
    },
    config = function()
      -- Same heavy trees we prune for Telescope + rust-analyzer. submodules is
      -- tracked (not gitignored) so it must be excluded explicitly.
      local excludes = { '.git', 'submodules', 'target', 'node_modules', 'bazel-out', '.venv' }
      local globs = ''
      for _, d in ipairs(excludes) do
        globs = globs .. string.format(" --glob '!%s/*'", d)
      end

      require('fzf-lua').setup({
        -- 'max-perf' profile tuning: keep previews cheap, results streaming.
        files = {
          -- Use rg for consistency with the rest of the config. Respects .gitignore
          -- by default; the explicit globs drop the tracked-but-huge trees too.
          cmd = 'rg --files --hidden' .. globs,
        },
        grep = {
          rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden'
            .. globs,
        },
        winopts = {
          height = 0.85,
          width = 0.85,
          preview = { layout = 'vertical', vertical = 'down:45%' },
        },
      })
    end,
  },
}
