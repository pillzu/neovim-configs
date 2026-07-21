-- groktmux.feed — assemble a context block and paste it into the Grok tmux pane.
--
-- Normal: cursor line ± context_lines + path header, then ask for a task.
-- Visual: the selection is the code context (not cursor ± N).
-- On send: write the current buffer if modified so disk matches the excerpt.

local M = {}

local tmux = require('groktmux.tmux')

M.context_lines = 3

local function in_visual()
  local m = vim.fn.mode()
  return m == 'v' or m == 'V' or m == '\22'
end

local function exit_visual()
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)
end

local function format_line_range(start_line, end_line)
  if start_line == end_line then
    return tostring(start_line)
  end
  return start_line .. '-' .. end_line
end

local function buffer_relpath()
  return vim.fn.expand('%:.')
end

--- Line range for an active visual selection (uses v / . while still visual).
local function active_visual_lines()
  local s = vim.fn.getpos('v')
  local e = vim.fn.getpos('.')
  local sl, el = s[2], e[2]
  if sl > el then
    sl, el = el, sl
  end
  return sl, el
end

--- Text for an active character/line/block visual selection.
local function active_visual_text()
  local mode = vim.fn.mode()
  local s = vim.fn.getpos('v')
  local e = vim.fn.getpos('.')
  local sl, sc, el, ec = s[2], s[3], e[2], e[3]
  if sl > el or (sl == el and sc > ec) then
    sl, sc, el, ec = el, ec, sl, sc
  end

  local lines = vim.api.nvim_buf_get_lines(0, sl - 1, el, false)
  if #lines == 0 then
    return ''
  end

  if mode == 'V' then
    -- linewise: full lines
  elseif mode == '\22' then
    for i, line in ipairs(lines) do
      lines[i] = string.sub(line, sc, ec)
    end
  else
    if #lines == 1 then
      lines[1] = string.sub(lines[1], sc, ec)
    else
      lines[1] = string.sub(lines[1], sc)
      lines[#lines] = string.sub(lines[#lines], 1, ec)
    end
  end

  return table.concat(lines, '\n')
end

--- @param visual boolean
--- @return table
local function resolve_target(visual)
  local relpath = buffer_relpath()
  local bufnr = vim.api.nvim_get_current_buf()
  local total = vim.api.nvim_buf_line_count(bufnr)

  if visual then
    local start_line, end_line, excerpt
    if in_visual() then
      start_line, end_line = active_visual_lines()
      excerpt = active_visual_text()
    else
      -- marks after leaving visual (e.g. :'<,'>GrokAsk)
      local s = vim.fn.getpos("'<")
      local e = vim.fn.getpos("'>")
      start_line, end_line = s[2], e[2]
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end
      excerpt = table.concat(
        vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false),
        '\n'
      )
    end
    return {
      path = relpath,
      start_line = start_line,
      end_line = end_line,
      excerpt = excerpt,
    }
  end

  local cur = vim.fn.line('.')
  local start_line = math.max(1, cur - M.context_lines)
  local end_line = math.min(total, cur + M.context_lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  return {
    path = relpath,
    start_line = start_line,
    end_line = end_line,
    excerpt = table.concat(lines, '\n'),
  }
end

--- @param target table
--- @param task string
--- @return string
function M.compose(target, task)
  local header = target.path .. ':' .. format_line_range(target.start_line, target.end_line)
  return table.concat({
    task,
    '',
    header,
    '```',
    target.excerpt,
    '```',
  }, '\n')
end

local function write_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.bo[bufnr].modifiable or not vim.bo[bufnr].modified then
    return
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' or vim.bo[bufnr].buftype ~= '' then
    return
  end
  local ok, err = pcall(function()
    vim.cmd('silent write')
  end)
  if not ok then
    vim.notify('[groktmux] Could not save buffer before feed: ' .. tostring(err), vim.log.levels.WARN)
  end
end

--- @param opts table|nil  { visual = boolean }
function M.dispatch(opts)
  opts = opts or {}
  local visual = opts.visual
  if visual == nil then
    visual = in_visual()
  end

  local target = resolve_target(visual)
  if in_visual() then
    exit_visual()
  end

  vim.ui.input({ prompt = 'Grok: ' }, function(task)
    if not task or vim.trim(task) == '' then
      vim.notify('[groktmux] Feed cancelled (empty task).', vim.log.levels.INFO)
      return
    end
    write_current_buffer()
    tmux.send(M.compose(target, task))
  end)
end

return M
