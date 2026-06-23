-- groktmux.tmux — pane discovery + context delivery into the Grok tmux pane.
--
-- Delivery uses a tmux buffer + bracketed paste so that a multi-line context block
-- is handed to Grok's TUI as ONE prompt (not N separate submits, which is what you
-- get if you naively `send-keys` text containing newlines). After pasting we send a
-- single Enter to submit.
--
-- Everything degrades gracefully: outside tmux (no $TMUX), or if no Grok pane is
-- found, send() falls back to the system clipboard and tells the user to paste.

local M = {}

-- Cached target pane id (e.g. "%3"). Set by find_grok_pane() or attach().
M._pane = nil

--- Are we running inside tmux?
--- @return boolean
local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ''
end

--- Run a tmux command synchronously, returning trimmed stdout (or nil on failure).
--- @param args string[]  arguments after the `tmux` binary
--- @return string|nil stdout, string|nil err
local function tmux(args)
  -- vim.system blocks here with :wait(); these calls are tiny + local so the
  -- cost is negligible and synchronous is simpler than threading callbacks.
  local res = vim.system(vim.list_extend({ 'tmux' }, args), { text = true }):wait()
  if res.code ~= 0 then
    return nil, (res.stderr or 'tmux failed')
  end
  return vim.trim(res.stdout or ''), nil
end

--- Validate that a pane id still exists.
--- @param pane string
--- @return boolean
local function pane_alive(pane)
  if not pane or pane == '' then
    return false
  end
  local out = tmux({ 'list-panes', '-a', '-F', '#{pane_id}' })
  if not out then
    return false
  end
  for line in (out .. '\n'):gmatch('([^\n]*)\n') do
    if line == pane then
      return true
    end
  end
  return false
end

--- Discover the Grok pane: the pane in the current window whose foreground command
--- is not nvim. Falls back to the first non-nvim pane anywhere.
--- @return string|nil pane_id
function M.find_grok_pane()
  if not in_tmux() then
    return nil
  end
  if M._pane and pane_alive(M._pane) then
    return M._pane
  end

  -- Prefer the current window, then widen to all panes.
  for _, scope in ipairs({ {}, { '-a' } }) do
    local args = { 'list-panes' }
    vim.list_extend(args, scope)
    vim.list_extend(args, { '-F', '#{pane_id} #{pane_current_command}' })
    local out = tmux(args)
    if out then
      for line in (out .. '\n'):gmatch('([^\n]*)\n') do
        local pid, cmd = line:match('^(%%%d+)%s+(.+)$')
        -- Skip our own nvim pane; anything else (a shell running grok, the grok
        -- binary itself, etc.) is a candidate.
        if pid and cmd and not cmd:match('n?vim') then
          M._pane = pid
          return pid
        end
      end
    end
  end
  return nil
end

--- Manually bind the Grok pane (used by :GrokAttachPane). With no arg, re-discovers.
--- @param pane string|nil
--- @return string|nil pane_id
function M.attach(pane)
  if pane and pane ~= '' then
    M._pane = pane
    return pane
  end
  M._pane = nil
  return M.find_grok_pane()
end

--- Deliver a (possibly multi-line) context block to Grok.
--- Returns true if sent via tmux, false if it fell back to the clipboard.
--- @param text string
--- @return boolean sent_via_tmux
function M.send(text)
  local pane = M.find_grok_pane()
  if not pane then
    -- Fallback: clipboard, so the workflow still works outside tmux.
    vim.fn.setreg('+', text)
    vim.notify('[groktmux] No Grok pane found — context copied to clipboard. Paste into Grok.', vim.log.levels.WARN)
    return false
  end

  -- Load the text into a named tmux buffer via stdin, then bracketed-paste it into
  -- the target pane. -p = bracketed paste (TUI sees one chunk), -d = delete buffer
  -- after pasting so it doesn't accumulate.
  local load = vim.system({ 'tmux', 'load-buffer', '-b', 'grokfeed', '-' }, { stdin = text }):wait()
  if load.code ~= 0 then
    vim.fn.setreg('+', text)
    vim.notify('[groktmux] tmux load-buffer failed — copied to clipboard instead.', vim.log.levels.WARN)
    return false
  end
  tmux({ 'paste-buffer', '-b', 'grokfeed', '-t', pane, '-p', '-d' })
  -- Submit. Separate send-keys so the Enter is a real key, not pasted text.
  tmux({ 'send-keys', '-t', pane, 'Enter' })
  vim.notify('[groktmux] Fed context to Grok pane ' .. pane, vim.log.levels.INFO)
  return true
end

return M
