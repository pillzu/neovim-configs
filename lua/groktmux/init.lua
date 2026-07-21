-- groktmux — feed context from Neovim into a Grok tmux pane (tmux paste only).

local M = {}

M.feed = require('groktmux.feed')
M.tmux = require('groktmux.tmux')

function M.setup(opts)
  opts = opts or {}
  if opts.context_lines then
    M.feed.context_lines = opts.context_lines
  end

  local cmd = vim.api.nvim_create_user_command

  cmd('GrokAsk', function(o)
    -- range > 0 when invoked as :'<,'>GrokAsk from visual
    M.feed.dispatch({ visual = o.range > 0 })
  end, { range = true, desc = 'Grok: ask with buffer/selection context' })

  cmd('GrokAttachPane', function(o)
    local p = M.tmux.attach(o.args ~= '' and o.args or nil)
    vim.notify('[groktmux] Grok pane = ' .. tostring(p), vim.log.levels.INFO)
  end, { nargs = '?', desc = 'Grok: bind (or re-discover) the Grok tmux pane' })
end

return M
