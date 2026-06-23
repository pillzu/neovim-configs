-- Hot reload module for auto-reloading files when grok CLI edits them
-- This ensures you see grok's changes in real-time without manual refreshing

local M = {}

-- Check if we should perform a reload check
local function should_check()
  -- Don't check in these modes
  local mode = vim.fn.mode()
  if mode == 'c' or mode == 'r' then
    return false
  end
  return true
end

-- Check if a buffer should be reloaded
local function should_reload_buffer(buf)
  -- Must be a valid buffer
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  -- Must be loaded
  if not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end

  -- Skip if buffer is modified (user has unsaved changes)
  if vim.bo[buf].modified then
    return false
  end

  -- Skip special buffers
  local buftype = vim.bo[buf].buftype
  if buftype ~= '' then
    return false
  end

  -- Must have a filename
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return false
  end

  -- Skip special buffer names (like diffview://)
  if name:match('^diffview://') or name:match('^fugitive://') or name:match('^gitsigns://') then
    return false
  end

  -- Check file exists
  if vim.fn.filereadable(name) ~= 1 then
    return false
  end

  return true
end

-- Get all visible buffers
local function get_visible_buffers()
  local visible_bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    visible_bufs[buf] = true
  end
  return visible_bufs
end

-- Find buffer by filepath
local function find_buffer_by_filepath(filepath)
  -- Normalize the filepath
  local cwd = vim.fn.getcwd()
  local abs_path = vim.fn.fnamemodify(cwd .. '/' .. filepath, ':p')
  
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name == abs_path or buf_name == filepath then
      return buf
    end
  end
  return nil
end

-- Setup hotreload functionality
M.setup = function(opts)
  opts = opts or {}

  -- Register handler with directory watcher for fs_event-based reloading
  local ok, dir_watcher = pcall(require, 'custom.directory-watcher')
  if ok then
    dir_watcher.registerOnChangeHandler('hotreload', function(filepath, events)
      if not should_check() then
        return
      end
      
      local buf = find_buffer_by_filepath(filepath)
      if buf and should_reload_buffer(buf) then
        vim.cmd('checktime ' .. buf)
      end
    end)
    
    -- Start the directory watcher
    dir_watcher.autostart()
  end

  -- Create autocmds for additional trigger events
  vim.api.nvim_create_autocmd({
    'FocusGained',  -- When neovim window gains focus
    'TermLeave',    -- When leaving terminal mode
    'BufEnter',     -- When entering a buffer
    'WinEnter',     -- When entering a window
    'CursorHold',   -- After cursor is idle for updatetime
    'CursorHoldI',  -- Same but in insert mode
  }, {
    group = vim.api.nvim_create_augroup('HotReload', { clear = true }),
    callback = function()
      if should_check() then
        -- Check all buffers for external changes
        vim.cmd('checktime')
      end
    end,
  })

  -- Enable autoread so :checktime actually reloads
  vim.o.autoread = true
end

return M
