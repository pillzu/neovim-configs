-- groktmux — Grok <-> Neovim integration via tmux + post-disk review.
--
-- Flow:
--   1. Feed   (:GrokAsk / <leader>gg) — snapshot the tree, build a context block
--      (target line/range + current unsaved buffer), bracketed-paste it into the
--      Grok tmux pane. Anti-clobber: Grok edits from your real current state.
--   2. Grok edits on disk (in its tmux pane); your hotreload reloads buffers.
--   3. Review — auto-fires when Grok's writes go quiet (scoped fs_event quiescence),
--      repointing gitsigns' base at the snapshot so reject/keep/modify happen with
--      your existing gitsigns keys; diffview gives the cross-file walk.
--
-- No ACP, no JSON-RPC, no FS proxy. Thin layer over tmux + gitsigns + diffview.

local M = {}

M.feed = require('groktmux.feed')
M.review = require('groktmux.review')
M.tmux = require('groktmux.tmux')

function M.setup(opts)
  opts = opts or {}
  if opts.context_lines then
    M.feed.context_lines = opts.context_lines
  end
  if opts.debounce_ms then
    require('groktmux.detect').debounce_ms = opts.debounce_ms
  end

  local cmd = vim.api.nvim_create_user_command

  -- Ask: send context only. No snapshot, no auto-review (questions / hand-dive help).
  cmd('GrokAsk', function(o)
    M.feed.dispatch({ mode = (o.range > 0) and 'v' or nil, edit = false })
  end, { range = true, desc = 'Grok: ask with context (no review)' })

  -- Edit: send context + snapshot + arm auto-review (Grok will change files).
  cmd('GrokEdit', function(o)
    M.feed.dispatch({ mode = (o.range > 0) and 'v' or nil, edit = true, include_diff = false })
  end, { range = true, desc = 'Grok: edit task with context (arms review)' })

  cmd('GrokEditDiff', function(o)
    M.feed.dispatch({ mode = (o.range > 0) and 'v' or nil, edit = true, include_diff = true })
  end, { range = true, desc = 'Grok: edit task with context + git diff (arms review)' })

  cmd('GrokReview', function()
    M.review.open()
  end, { desc = 'Grok: open review of changeset (manual)' })

  cmd('GrokReviewClear', function()
    M.review.clear()
  end, { desc = 'Grok: end review, restore gitsigns base' })

  cmd('GrokAttachPane', function(o)
    local p = M.tmux.attach(o.args ~= '' and o.args or nil)
    vim.notify('[groktmux] Grok pane = ' .. tostring(p), vim.log.levels.INFO)
  end, { nargs = '?', desc = 'Grok: bind (or re-discover) the Grok tmux pane' })
end

return M
