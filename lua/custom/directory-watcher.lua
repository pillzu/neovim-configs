-- Directory watcher module for detecting file changes (for grok CLI integration)
-- Uses libuv fs_event for efficient filesystem monitoring

local M = {}

local uv = vim.uv or vim.loop
local watcher = nil
local debounce_timer = nil
local on_change_handlers = {}

-- Debounce helper to avoid excessive callbacks
local function debounce(fn, delay)
  return function(...)
    local args = { ... }
    if debounce_timer then
      debounce_timer:stop()
    end
    debounce_timer = vim.defer_fn(function()
      fn(unpack(args))
    end, delay)
  end
end

-- Register a handler for file changes
-- @param name string: unique name for the handler
-- @param handler function(filepath, events): callback when files change
M.registerOnChangeHandler = function(name, handler)
  on_change_handlers[name] = handler
end

-- Unregister a handler
M.unregisterOnChangeHandler = function(name)
  on_change_handlers[name] = nil
end

-- Notify all registered handlers of a file change
local function notifyHandlers(filepath, events)
  for _, handler in pairs(on_change_handlers) do
    local ok, err = pcall(handler, filepath, events)
    if not ok then
      vim.notify("Directory watcher handler error: " .. tostring(err), vim.log.levels.WARN)
    end
  end
end

-- Setup the directory watcher
-- @param opts table: { path = string, debounce_ms = number }
M.setup = function(opts)
  opts = opts or {}
  local path = opts.path or vim.fn.getcwd()
  local debounce_ms = opts.debounce_ms or 100

  -- Stop any existing watcher
  M.stop()

  -- Create the file watcher
  watcher = uv.new_fs_event()

  if not watcher then
    vim.notify("Failed to create file watcher", vim.log.levels.ERROR)
    return
  end

  local debouncedNotify = debounce(notifyHandlers, debounce_ms)

  local flags = {
    watch_entry = false,  -- Watch entry vs directory itself
    stat = false,         -- Use stat to detect changes
    recursive = true,     -- Watch subdirectories (platform dependent)
  }

  local ok, err = watcher:start(path, flags, function(err, filename, events)
    if err then
      vim.schedule(function()
        vim.notify("File watcher error: " .. tostring(err), vim.log.levels.WARN)
      end)
      return
    end

    vim.schedule(function()
      debouncedNotify(filename, events)
    end)
  end)

  if not ok then
    vim.notify("Failed to start file watcher: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Stop the directory watcher
M.stop = function()
  if watcher then
    watcher:stop()
    watcher = nil
  end
  if debounce_timer then
    vim.fn.timer_stop(debounce_timer)
    debounce_timer = nil
  end
end

-- Automatically start watching when entering a directory
M.autostart = function()
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("DirectoryWatcher", { clear = true }),
    callback = function()
      M.setup({ path = vim.fn.getcwd() })
    end,
  })
end

return M
