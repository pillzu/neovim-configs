local M = {}

-- ******************************
--              Helpers
-- ******************************
-- In this case, we create a function that lets us more easily define mappings specific
-- for LSP related items. It sets the mode, buffer and description for us each time.
-- Helper function to define LSP-specific keymaps
local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end
  vim.keymap.set('n', keys, func, { buffer = true, desc = desc })
end

-- Function run when an LSP connects to a buffer
M.on_attach = function(_, bufnr)
  -- g-family for LSP (consistent navigation + actions)
  nmap('ga', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('rn', vim.lsp.buf.rename, '[R]e[n]ame')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gD', require('telescope.builtin').lsp_type_definitions, '[G]oto Type [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('gs', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('gws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('gK', vim.lsp.buf.signature_help, '[S]ignature [H]elp')

  -- Extra high-value LSP features (g-family)
  nmap('gih', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
  end, 'Toggle Inlay Hints')

  nmap('gci', function() require('telescope.builtin').lsp_incoming_calls() end, 'Incoming Calls')
  nmap('gco', function() require('telescope.builtin').lsp_outgoing_calls() end, 'Outgoing Calls')

  nmap('gcl', function()
    vim.lsp.codelens.refresh({ bufnr = 0 })
    vim.lsp.codelens.run()
  end, 'CodeLens (Refresh + Run)')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')
  nmap('<leader>fm', vim.lsp.buf.format, '[F]or[m]at Code')

  -- Create a buffer-local :Format command
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local cmd_cache = {}
M.cmd_exists = function(cmd)
  if cmd_cache[cmd] ~= nil then return cmd_cache[cmd] end
  local ok = os.execute('command -v ' .. cmd .. ' >/dev/null 2>&1')
  local res = ok == 0
  cmd_cache[cmd] = res
  return res
end

return M
