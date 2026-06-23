-- Yank module for copying code with file paths
-- Perfect for pasting code references into grok CLI

local M = {}

-- Get absolute path of current buffer
M.get_buffer_absolute = function()
  return vim.fn.expand('%:p')
end

-- Get path relative to current working directory
M.get_buffer_cwd_relative = function()
  return vim.fn.expand('%:.')
end

-- Get visual selection bounds
-- Returns { start_line, start_col, end_line, end_col }
M.get_visual_bounds = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  return {
    start_line = start_pos[2],
    start_col = start_pos[3],
    end_line = end_pos[2],
    end_col = end_pos[3],
  }
end

-- Format line range as string
M.format_line_range = function(start_line, end_line)
  if start_line == end_line then
    return tostring(start_line)
  else
    return start_line .. '-' .. end_line
  end
end

-- Get current line number (for normal mode)
M.get_current_line = function()
  return vim.fn.line('.')
end

-- Simulate yank highlight effect
M.simulate_yank_highlight = function()
  -- Get the current visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  -- Create highlight namespace
  local ns = vim.api.nvim_create_namespace('yank_path_highlight')
  
  -- Highlight the visual selection briefly
  local buf = vim.api.nvim_get_current_buf()
  for line = start_pos[2], end_pos[2] do
    pcall(vim.api.nvim_buf_add_highlight, buf, ns, 'IncSearch', line - 1, 0, -1)
  end
  
  -- Clear highlight after a short delay
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end, 150)
end

-- Exit visual mode
M.exit_visual_mode = function()
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)
end

-- Yank a path to clipboard and notify
M.yank_path = function(path, label)
  vim.fn.setreg('+', path)
  vim.notify('Yanked ' .. label .. ' path: ' .. path, vim.log.levels.INFO)
end

-- Yank content with path prefix (for pasting into grok)
M.yank_with_path = function(path, content, label)
  local full_text = path .. '\n' .. content
  vim.fn.setreg('+', full_text)
  vim.notify('Yanked ' .. label .. ' with content', vim.log.levels.INFO)
end

-- Get visual selection text
M.get_visual_selection = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    return ''
  end
  
  -- Handle partial first and last line in characterwise visual mode
  local mode = vim.fn.visualmode()
  if mode == 'v' then
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    lines[1] = string.sub(lines[1], start_pos[3])
  end
  
  return table.concat(lines, '\n')
end

-- Setup keymaps for yanking with paths
M.setup = function(opts)
  opts = opts or {}
  
  -- Visual mode: yank selection with relative path
  vim.keymap.set('v', '<leader>yr', function()
    -- Exit visual mode first to set '< and '> marks
    M.exit_visual_mode()
    vim.schedule(function()
      M.simulate_yank_highlight()
      local bounds = M.get_visual_bounds()
      local relpath = M.get_buffer_cwd_relative()
      local line_range = M.format_line_range(bounds.start_line, bounds.end_line)
      local path = relpath .. ':' .. line_range
      M.yank_path(path, 'relative')
    end)
  end, { desc = 'Yank visual selection with relative path' })
  
  -- Visual mode: yank selection with absolute path
  vim.keymap.set('v', '<leader>ya', function()
    M.exit_visual_mode()
    vim.schedule(function()
      M.simulate_yank_highlight()
      local bounds = M.get_visual_bounds()
      local abspath = M.get_buffer_absolute()
      local line_range = M.format_line_range(bounds.start_line, bounds.end_line)
      local path = abspath .. ':' .. line_range
      M.yank_path(path, 'absolute')
    end)
  end, { desc = 'Yank visual selection with absolute path' })
  
  -- Visual mode: yank content with relative path prefix
  vim.keymap.set('v', '<leader>yp', function()
    M.exit_visual_mode()
    vim.schedule(function()
      M.simulate_yank_highlight()
      local bounds = M.get_visual_bounds()
      local relpath = M.get_buffer_cwd_relative()
      local line_range = M.format_line_range(bounds.start_line, bounds.end_line)
      local path = relpath .. ':' .. line_range
      local content = M.get_visual_selection()
      M.yank_with_path(path, content, 'relative')
    end)
  end, { desc = 'Yank content with relative path prefix' })
  
  -- Normal mode: yank current file relative path with line number
  vim.keymap.set('n', '<leader>yr', function()
    local relpath = M.get_buffer_cwd_relative()
    local line = M.get_current_line()
    local path = relpath .. ':' .. line
    M.yank_path(path, 'relative')
  end, { desc = 'Yank relative path with line number' })
  
  -- Normal mode: yank current file absolute path with line number
  vim.keymap.set('n', '<leader>ya', function()
    local abspath = M.get_buffer_absolute()
    local line = M.get_current_line()
    local path = abspath .. ':' .. line
    M.yank_path(path, 'absolute')
  end, { desc = 'Yank absolute path with line number' })
  
  -- Normal mode: yank just the relative file path (no line number)
  vim.keymap.set('n', '<leader>yf', function()
    local relpath = M.get_buffer_cwd_relative()
    M.yank_path(relpath, 'relative file')
  end, { desc = 'Yank relative file path' })
  
  -- Normal mode: yank just the absolute file path (no line number)
  vim.keymap.set('n', '<leader>yF', function()
    local abspath = M.get_buffer_absolute()
    M.yank_path(abspath, 'absolute file')
  end, { desc = 'Yank absolute file path' })
end

return M
