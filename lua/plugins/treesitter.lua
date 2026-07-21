return {
  {
    -- Highlight, edit, and navigate code
    -- Neovim 0.12+ requires the rewrite on `main` (master is archived / broken).
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- README: does not support lazy-loading. If this loads after FileType for a
    -- startup buffer (e.g. nvim foo.yaml), highlighting never attaches — and
    -- yaml has no LSP semantic tokens as a fallback (unlike rust/go/python).
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
      'https://github.com/windwp/nvim-ts-autotag',
    },
    build = ':TSUpdate',
    config = function()
      local config = require 'config'
      local ts = require 'nvim-treesitter'
      local ts_config = require 'nvim-treesitter.config'

      -- Default install dir is stdpath('data')/site (parsers + query symlinks).
      ts.setup {}

      -- Install any missing parsers from the list (main no longer uses ensure_installed opts).
      local installed = ts_config.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, config.ts_ensure_installed)
      if #missing > 0 then
        -- Async is fine; FileType handler retries start after install via re-open,
        -- and we kick already-open buffers below after a short wait.
        ts.install(missing)
      end

      local function start_ts(buf)
        buf = buf or 0
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local ft = vim.bo[buf].filetype
        if ft == '' then
          return
        end
        -- pcall: missing parser for exotic fts is expected.
        local ok = pcall(vim.treesitter.start, buf)
        if ok then
          -- Experimental TS indent; safe no-op if unsupported for the lang.
          pcall(function()
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('NvimTreesitterSetup', { clear = true }),
        callback = function(ev)
          start_ts(ev.buf)
        end,
      })

      -- Attach to buffers that already have a filetype (opened before this config ran,
      -- or race with install). Harmless if TS is already running.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
          start_ts(buf)
        end
      end

      -- If we kicked off installs, re-try open buffers once parsers land.
      if #missing > 0 then
        vim.defer_fn(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
              start_ts(buf)
            end
          end
        end, 5000)
      end

      pcall(function()
        require('nvim-ts-autotag').setup {}
      end)
    end,
  },
}
