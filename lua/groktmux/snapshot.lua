-- groktmux.snapshot — capture a baseline of the working tree at feed-dispatch time.
--
-- `git stash create` builds a commit object capturing the current working tree +
-- index WITHOUT touching the tree, the stash list, or HEAD. It returns that commit's
-- SHA (or empty output if the tree is clean). We diff Grok's later writes against
-- this SHA so the review shows exactly what Grok changed — cleanly separated from any
-- uncommitted work you already had.

local M = {}

-- Active baseline SHA (or 'HEAD'). nil when no review session is armed.
M._base = nil

--- Take a snapshot and arm the review/detect machinery.
--- Async (vim.system + callback) so a slow git in a big repo never blocks the UI.
function M.take()
  vim.system({ 'git', 'stash', 'create' }, { text = true }, function(res)
    local sha = (res.code == 0) and vim.trim(res.stdout or '') or ''
    -- Clean tree → stash create prints nothing; fall back to HEAD as the baseline.
    M._base = (sha ~= '') and sha or 'HEAD'
    vim.schedule(function()
      require('groktmux.detect').arm()
      vim.notify('[groktmux] Baseline snapshot: ' .. M._base:sub(1, 12), vim.log.levels.DEBUG)
    end)
  end)
end

--- Current baseline SHA, or nil if none armed.
--- @return string|nil
function M.current()
  return M._base
end

--- Clear the baseline (called when a review session ends).
function M.clear()
  M._base = nil
end

return M
