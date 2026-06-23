-- groktmux.detect — auto-trigger review when Grok finishes a turn.
--
-- There is no clean "turn done" signal from a terminal Grok, so we use a heuristic:
-- file-write quiescence. After a feed dispatch we arm a set of libuv fs_event
-- watchers; once writes occur and then go quiet for `debounce_ms`, we fire the
-- review. This is event-driven (not polling) and prompt-independent.
--
-- REPO SAFETY: we deliberately do NOT watch the repo root recursively (that is
-- the trap the global custom/directory-watcher falls into). We watch only the
-- directories of currently-open buffers, and grow the set one directory at a time as
-- write events arrive — never the whole tree. Each watcher is non-recursive.
--
-- RE-FIRE SAFETY: firing review is non-destructive and the baseline stays pinned to
-- the dispatch snapshot, so if Grok writes more after review opened, we just refresh
-- diffview and the new edits appear as additional hunks.

local M = {}

local uv = vim.uv or vim.loop

M.debounce_ms = 1800        -- quiet window after a write burst before firing
M.max_idle_ms = 5 * 60 * 1000 -- hard cap: disarm a dangling session after this

M._armed = false
M._watchers = {}            -- dir -> uv_fs_event handle
M._debounce = nil           -- uv_timer
M._cap = nil                -- uv_timer (hard cap)
M._fired = false            -- whether we've fired at least once this session

--- Stop and close a single watcher handle safely.
local function close_handle(h)
  if h then
    pcall(function() h:stop() end)
    pcall(function() if not h:is_closing() then h:close() end end)
  end
end

--- Watch one directory (non-recursive) if not already watched.
--- @param dir string
local function watch_dir(dir)
  if not dir or dir == '' or M._watchers[dir] then
    return
  end
  if vim.fn.isdirectory(dir) ~= 1 then
    return
  end
  local handle = uv.new_fs_event()
  if not handle then
    return
  end
  -- recursive=false: a single directory level only. Cheap regardless of repo size.
  local ok = pcall(function()
    handle:start(dir, {}, function(err, filename)
      if err then
        return
      end
      vim.schedule(function()
        M._on_write(dir, filename)
      end)
    end)
  end)
  if ok then
    M._watchers[dir] = handle
  else
    close_handle(handle)
  end
end

--- Collect directories of all currently-open, file-backed buffers.
--- @return string[]
local function open_buffer_dirs()
  local seen, dirs = {}, {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' and vim.fn.filereadable(name) == 1 then
        local dir = vim.fn.fnamemodify(name, ':h')
        if dir ~= '' and not seen[dir] then
          seen[dir] = true
          dirs[#dirs + 1] = dir
        end
      end
    end
  end
  return dirs
end

--- A write was observed. Grow the watch set toward the touched file's dir and reset
--- the debounce timer.
function M._on_write(dir, filename)
  if not M._armed then
    return
  end
  -- Grow: if the event named a subdir/file, also watch its directory.
  if filename and filename ~= '' then
    local touched = dir .. '/' .. filename
    if vim.fn.isdirectory(touched) == 1 then
      watch_dir(touched)
    end
  end

  if M._debounce then
    M._debounce:stop()
  else
    M._debounce = uv.new_timer()
  end
  M._debounce:start(M.debounce_ms, 0, vim.schedule_wrap(function()
    if not M._armed then
      return
    end
    local review = require('groktmux.review')
    local base = require('groktmux.snapshot').current()
    -- Only act if Grok actually changed something vs the baseline. An incidental
    -- write (formatter, swap file, our own buffer save) must not pop a review.
    if not base or not review.has_changes(base) then
      return
    end
    M._fired = true
    review.open(base)
    -- Stay armed after firing: late writes will re-fire / refresh diffview.
    pcall(vim.cmd, 'DiffviewRefresh')
  end))
end

--- Arm detection (called by snapshot.take). Idempotent.
function M.arm()
  M.disarm() -- clean slate
  M._armed = true
  M._fired = false
  for _, dir in ipairs(open_buffer_dirs()) do
    watch_dir(dir)
  end
  -- Hard cap so a forgotten session doesn't leave watchers running forever.
  M._cap = uv.new_timer()
  M._cap:start(M.max_idle_ms, 0, vim.schedule_wrap(function()
    if M._armed then
      vim.notify('[groktmux] Auto-review watcher idle-timeout; disarming.', vim.log.levels.DEBUG)
      M.disarm()
    end
  end))
end

--- Disarm and tear down all watchers/timers.
function M.disarm()
  M._armed = false
  for dir, h in pairs(M._watchers) do
    close_handle(h)
    M._watchers[dir] = nil
  end
  if M._debounce then
    close_handle(M._debounce)
    M._debounce = nil
  end
  if M._cap then
    close_handle(M._cap)
    M._cap = nil
  end
end

return M
