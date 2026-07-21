-- fff.nvim — Rust-backed file + content search with a warm index, frecency, and
-- git-aware ranking. Owns <leader>ff / <leader>fg. Telescope keeps LSP / buffers
-- / diagnostics / help (see plugins/telescope.lua).

--- fff's default list label is `basename  dir/…`, and the dir is the first thing
--- dropped when the list is narrow — so monorepo hits look identical (`main.rs`).
--- Prefer the full repo-relative path as the primary label; shorten from the
--- start only when it still doesn't fit.
local function patch_relative_path_display()
  local ok_fr, file_renderer = pcall(require, 'fff.picker_ui.file_renderer')
  if not ok_fr or file_renderer._relpath_display_patched then
    return
  end

  local function format_rel(item, max_width)
    local rel = item.relative_path or item.name or ''
    if type(rel) ~= 'string' then
      rel = tostring(rel or '')
    end
    if rel == '' then
      return '', ''
    end
    if vim.fn.strdisplaywidth(rel) <= max_width then
      return rel, ''
    end
    local conf = require('fff.conf').get()
    local strategy = (conf.layout and conf.layout.path_shorten_strategy) or 'start'
    local ok_rust, rust = pcall(require, 'fff.rust')
    if ok_rust and rust.shorten_path then
      return rust.shorten_path(rel, max_width, strategy), ''
    end
    -- Fallback: keep the tail of the path.
    local keep = math.max(1, max_width - 1)
    return '…' .. rel:sub(#rel - keep + 2), ''
  end

  local function with_rel(ctx, fn, ...)
    local saved = ctx.format_file_display
    ctx.format_file_display = format_rel
    local results = { pcall(fn, ...) }
    ctx.format_file_display = saved
    if not results[1] then
      error(results[2])
    end
    return unpack(results, 2)
  end

  local orig_render = file_renderer.render_line
  local orig_hl = file_renderer.apply_highlights

  function file_renderer.render_line(item, ctx, ...)
    return with_rel(ctx, orig_render, item, ctx, ...)
  end

  function file_renderer.apply_highlights(item, ctx, ...)
    return with_rel(ctx, orig_hl, item, ctx, ...)
  end

  file_renderer._relpath_display_patched = true
end

return {
  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      require('fff.download').download_or_build_binary()
    end,
    -- Plugin self-lazy-inits the Rust runtime; load on first keypress / command.
    lazy = false,
    keys = {
      {
        '<leader>ff',
        function()
          require('fff').find_files()
        end,
        desc = '[F]ind [F]iles (fff)',
      },
      {
        '<leader>fg',
        function()
          require('fff').live_grep()
        end,
        desc = '[F]ind by [G]rep (fff)',
      },
      {
        '<leader>fw',
        function()
          require('fff').live_grep_under_cursor()
        end,
        mode = { 'n', 'x' },
        desc = '[F]ind [W]ord / selection (fff)',
      },
      {
        '<leader>f/',
        function()
          require('fff').find_files_in_dir(vim.fn.expand('%:p:h'))
        end,
        desc = '[F]ind files in buffer dir (fff)',
      },
    },
    cmd = {
      'FFFFind',
      'FFFScan',
      'FFFRefreshGit',
      'FFFClearCache',
      'FFFHealth',
      'FFFDebug',
      'FFFOpenLog',
    },
    opts = {
      -- Never accidentally index $HOME if someone opens nvim there.
      enable_home_dir_scanning = false,
      enable_fs_root_scanning = false,
      follow_symlinks = false, -- bazel-* symlinks on mono
      lazy_sync = true,
      max_results = 100,
      max_threads = 8,
      layout = {
        height = 0.85,
        width = 0.9,
        preview_position = 'right',
        preview_size = 0.4,
        -- When a path still doesn't fit: keep the end (crate/file), drop the start.
        path_shorten_strategy = 'start',
      },
      preview = {
        enabled = true,
        max_size = 1024 * 1024, -- 1M; skip huge blobs in preview
      },
      frecency = {
        enabled = true,
      },
      history = {
        enabled = true,
      },
      grep = {
        max_file_size = 1024 * 1024,
        max_matches_per_file = 50,
        smart_case = true,
        time_budget_ms = 150,
        modes = { 'plain', 'regex', 'fuzzy' },
      },
      debug = {
        enabled = false,
        show_scores = false,
        -- Full absolute path in the F2 debug info panel if you need it.
        show_file_info = { full_path = true },
      },
    },
    config = function(_, opts)
      require('fff').setup(opts)
      patch_relative_path_display()
    end,
  },
}
