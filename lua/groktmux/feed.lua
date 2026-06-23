-- groktmux.feed — assemble a context block and dispatch it to Grok.
--
-- The feed is the anti-clobber mechanism: it hands Grok the CURRENT state of the
-- file (including unsaved buffer edits) plus a precise target line/range, so Grok
-- edits from reality instead of a stale memory of the file.
--
-- Dispatch order matters: we snapshot the working tree (the review baseline) right
-- before sending, so "Grok's changeset" == everything that changed after this feed.

local M = {}

local tmux = require('groktmux.tmux')
local yank = require('custom.yank')

-- Lines of context to include around the cursor when there is no visual selection.
M.context_lines = 3

--- Determine the target: {path, start_line, end_line, excerpt}.
--- Uses the visual selection if one was just made, else current line ± context_lines.
--- @param mode string  'v' for visual-originated invocation, else normal
--- @return table
local function resolve_target(mode)
  local relpath = yank.get_buffer_cwd_relative()
  local bufnr = vim.api.nvim_get_current_buf()
  local total = vim.api.nvim_buf_line_count(bufnr)

  local start_line, end_line
  if mode == 'v' then
    -- Visual marks ('< '>) are set when leaving visual mode.
    local b = yank.get_visual_bounds()
    start_line, end_line = b.start_line, b.end_line
  else
    local cur = yank.get_current_line()
    start_line = math.max(1, cur - M.context_lines)
    end_line = math.min(total, cur + M.context_lines)
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  return {
    path = relpath,
    start_line = start_line,
    end_line = end_line,
    excerpt = table.concat(lines, '\n'),
  }
end

--- Build the full context string sent to Grok.
--- @param target table   from resolve_target
--- @param task string    the user's instruction
--- @param include_diff boolean
--- @return string
function M.compose(target, task, include_diff)
  local header = target.path .. ':' .. yank.format_line_range(target.start_line, target.end_line)
  local parts = {
    task,
    '',
    header,
    '```',
    target.excerpt,
    '```',
  }

  if include_diff then
    local res = vim.system(
      { 'git', 'diff', '-U3', '--', target.path },
      { text = true }
    ):wait()
    local diff = res.code == 0 and vim.trim(res.stdout or '') or ''
    if diff ~= '' then
      vim.list_extend(parts, { '', 'Current uncommitted diff for this file:', '```diff', diff, '```' })
    end
  end

  return table.concat(parts, '\n')
end

--- Entry point. Prompts for the task, composes, and dispatches.
--- Two intents:
---   edit=false (ask): just send context. No snapshot, no auto-review watcher.
---   edit=true:        snapshot the tree + arm auto-review, because Grok will edit.
--- @param opts table|nil  { mode = 'v'|nil, include_diff = boolean, edit = boolean }
function M.dispatch(opts)
  opts = opts or {}
  local target = resolve_target(opts.mode)
  local prompt = opts.edit and 'Grok edit task: ' or 'Grok question: '

  vim.ui.input({ prompt = prompt }, function(task)
    if not task or vim.trim(task) == '' then
      vim.notify('[groktmux] Feed cancelled (empty task).', vim.log.levels.INFO)
      return
    end

    -- Only arm the review machinery for edit intent. A plain question must not
    -- snapshot or start the fs_event watcher (otherwise an incidental write would
    -- pop a diffview review for a question that changed nothing).
    if opts.edit then
      require('groktmux.snapshot').take()
    end

    local text = M.compose(target, task, opts.include_diff)
    tmux.send(text)
  end)
end

return M
