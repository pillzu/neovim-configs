local M = {}

-- ******************************
--              Helpers
-- ******************************
-- In this case, we create a function that lets us more easily define mappings specific
-- for LSP related items. It sets the mode, buffer and description for us each time.
local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set('n', keys, func, { buffer = true, desc = desc })
end

--  This function gets run when an LSP connects to a particular buffer.
M.on_attach = function(_, bufnr)
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gs', vim.lsp.buf.signature_help, '[G]et [S]ignature help')
  nmap('<leader>gD', vim.lsp.buf.type_definition, '[G]oto Type [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('<leader>gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Format using fm
  nmap('<leader>fm', vim.lsp.buf.format, '[F]or[m]at Code')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

M.cmd_exists = function(cmd)
  local ok = os.execute('command -v ' .. cmd .. ' >/dev/null 2>&1')
  return ok == 0
end


M.windsurf_status = function()
  local status = require('codeium.virtual_text').status()

  if status.state == 'idle' then
    -- Output was cleared, for example when leaving insert mode
    return ' Idling'
  end

  if status.state == 'waiting' then
    -- Waiting for response
    return " Generating..."
  end

  if status.state == 'completions' and status.total > 0 then
    return string.format(' %d/%d', status.current, status.total)
  end
  vim.notify("I ran")

  return ' 0 '
end


return M
