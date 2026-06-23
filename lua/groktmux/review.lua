-- groktmux.review — show Grok's changeset using tooling already owned.
--
-- The whole review surface is your existing gitsigns + diffview. We just repoint
-- gitsigns' diff base at the dispatch snapshot, so every gutter sign, preview_hunk,
-- and reset_hunk is scoped to exactly what Grok changed. No vimdiff, no new keys:
--   reject hunk  = <leader>hr  (gitsigns reset_hunk → reverts to baseline)
--   keep hunk    = <leader>hs  (gitsigns stage_hunk) or just leave it
--   modify       = edit the file directly (it's on disk)
-- diffview gives the cross-file walk (<tab> / <s-tab>).

local M = {}

--- Are there any changes vs the baseline worth reviewing? Checks tracked diff AND
--- untracked files (Grok may create new files, which `git diff` alone misses).
--- @param base string
--- @return boolean
function M.has_changes(base)
  local diff = vim.system({ 'git', 'diff', '--quiet', base, '--' }, { text = true }):wait()
  if diff.code ~= 0 then
    return true -- non-zero = differences exist (or git error; err side is harmless)
  end
  local untracked = vim.system(
    { 'git', 'ls-files', '--others', '--exclude-standard' },
    { text = true }
  ):wait()
  return untracked.code == 0 and vim.trim(untracked.stdout or '') ~= ''
end

--- Open the review for the current baseline.
--- @param base string|nil  explicit base; defaults to the active snapshot
function M.open(base)
  base = base or require('groktmux.snapshot').current()
  if not base then
    vim.notify('[groktmux] No active snapshot to review. Run a feed first.', vim.log.levels.WARN)
    return
  end

  -- Guard: never pop a diff window when nothing actually changed. This is what
  -- prevents a spurious gitdiff opening on an incidental write.
  if not M.has_changes(base) then
    vim.notify('[groktmux] No changes vs baseline — nothing to review.', vim.log.levels.DEBUG)
    return
  end

  local ok_gs, gs = pcall(require, 'gitsigns')
  if ok_gs and gs.change_base then
    -- global=true so currently-open AND future buffers diff against the baseline.
    gs.change_base(base, true)
  else
    vim.notify('[groktmux] gitsigns not available; opening diffview only.', vim.log.levels.WARN)
  end

  -- diffview against the snapshot SHA → file panel of everything Grok touched.
  pcall(vim.cmd, 'DiffviewOpen ' .. base)
  vim.notify('[groktmux] Review open against ' .. base:sub(1, 12) .. ' (gitsigns base repointed).', vim.log.levels.INFO)
end

--- End the review session: restore gitsigns' normal base, close diffview, disarm.
function M.clear()
  local ok_gs, gs = pcall(require, 'gitsigns')
  if ok_gs and gs.change_base then
    gs.change_base(nil, true) -- nil restores the original (index/HEAD) base
  end
  pcall(vim.cmd, 'DiffviewClose')
  require('groktmux.detect').disarm()
  require('groktmux.snapshot').clear()
  vim.notify('[groktmux] Review cleared; gitsigns base restored.', vim.log.levels.INFO)
end

return M
