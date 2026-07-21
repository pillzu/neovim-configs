-- Hot reload: pick up external edits (Grok, other tools) without thrashing.
--
-- Design:
--   * Watch ONLY directories of open, file-backed buffers (non-recursive).
--   * Never watch the repo root recursively — that was the monorepo footgun.
--   * On FS events for a loaded file → checktime that buffer.
--   * FocusGained / TermLeave still call checktime as a belt-and-suspenders path
--     (tmux often needs focus-events on for FocusGained to fire).

local M = {}

local uv = vim.uv or vim.loop

--- @type table<string, uv.uv_fs_event_t>
local watchers = {}
local debounce_ms = 120
--- @type table<string, uv.uv_timer_t|any>
local pending = {}

local function should_check()
  local mode = vim.fn.mode()
  return mode ~= 'c' and mode ~= 'r'
end

--- @param buf integer
local function should_reload_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end
  if vim.bo[buf].modified then
    return false -- never clobber unsaved work
  end
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return false
  end
  if name:match('^diffview://') or name:match('^fugitive://') or name:match('^gitsigns://') then
    return false
  end
  if vim.fn.filereadable(name) ~= 1 then
    return false
  end
  return true
end

--- @param dir string
local function watch_dir(dir)
  if not dir or dir == '' or watchers[dir] then
    return
  end
  if vim.fn.isdirectory(dir) ~= 1 then
    return
  end
  local handle = uv.new_fs_event()
  if not handle then
    return
  end
  -- recursive=false: one directory level only — cheap regardless of repo size.
  local ok = pcall(function()
    handle:start(dir, {}, function(err, filename)
      if err or not filename or filename == '' then
        return
      end
      -- Debounce per directory+file so write bursts (formatters, grok) coalesce.
      local key = dir .. '\0' .. filename
      if pending[key] then
        pending[key]:stop()
      else
        pending[key] = uv.new_timer()
      end
      pending[key]:start(debounce_ms, 0, vim.schedule_wrap(function()
        pending[key] = nil
        if not should_check() then
          return
        end
        local path = dir .. '/' .. filename
        -- Resolve to absolute for buffer name match.
        path = vim.fn.fnamemodify(path, ':p')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            local bname = vim.api.nvim_buf_get_name(buf)
            if bname ~= '' and vim.fn.fnamemodify(bname, ':p') == path then
              if should_reload_buffer(buf) then
                vim.cmd('checktime ' .. buf)
              end
              break
            end
          end
        end
      end))
    end)
  end)
  if ok then
    watchers[dir] = handle
  else
    pcall(function()
      handle:stop()
      if not handle:is_closing() then
        handle:close()
      end
    end)
  end
end

local function unwatch_dir(dir)
  local h = watchers[dir]
  if not h then
    return
  end
  pcall(function()
    h:stop()
    if not h:is_closing() then
      h:close()
    end
  end)
  watchers[dir] = nil
end

--- Sync watch set to currently loaded file-backed buffers.
local function refresh_watches()
  local needed = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' and vim.fn.filereadable(name) == 1 then
        local dir = vim.fn.fnamemodify(name, ':p:h')
        if dir ~= '' then
          needed[dir] = true
          watch_dir(dir)
        end
      end
    end
  end
  for dir, _ in pairs(watchers) do
    if not needed[dir] then
      unwatch_dir(dir)
    end
  end
end

M.setup = function(opts)
  opts = opts or {}
  if opts.debounce_ms then
    debounce_ms = opts.debounce_ms
  end

  vim.o.autoread = true

  -- FS events for open buffers' directories only.
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufDelete', 'BufWipeout', 'DirChanged' }, {
    group = vim.api.nvim_create_augroup('HotReloadWatchers', { clear = true }),
    callback = function()
      vim.schedule(refresh_watches)
    end,
  })
  -- Initial set (after UI settles).
  vim.schedule(refresh_watches)

  -- Fallback when FS events are missed (network FS, some editors): refocus / leave term.
  vim.api.nvim_create_autocmd({ 'FocusGained', 'TermLeave', 'TermClose' }, {
    group = vim.api.nvim_create_augroup('HotReloadChecktime', { clear = true }),
    callback = function()
      if should_check() then
        vim.cmd('checktime')
      end
    end,
  })
end

M.refresh = refresh_watches

return M
