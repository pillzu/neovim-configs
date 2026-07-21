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

-- Paths that drown gr in dependency noise (cargo registry, git deps, rust-src).
-- Lua patterns matched by Telescope against the full file path.
M.lsp_ref_ignore_patterns = {
  '/%.cargo/',
  '/registry/src/',
  '/git/checkouts/',
  '/rustup/toolchains/',
  '/lib/rustlib/src/',
  '/target/rust%-analyzer/',
  '/target/debug/build/',
  '/target/release/build/',
}

--- Telescope LSP references, optionally including dependency sources.
--- @param opts table|nil  telescope opts; set include_deps=true for unfiltered
function M.lsp_references(opts)
  opts = opts or {}
  local include_deps = opts.include_deps
  opts.include_deps = nil

  local tb = require('telescope.builtin')
  local defaults = {
    jump_type = 'never',
    fname_width = 50,
    show_line = true,
    trim_text = true,
  }
  if not include_deps then
    defaults.file_ignore_patterns = M.lsp_ref_ignore_patterns
  end
  tb.lsp_references(vim.tbl_deep_extend('force', defaults, opts))
end

--- Dedupe quickfix-style LSP location items (same file+line from multiple clients).
--- @param items table[]
--- @return table[]
local function dedupe_locations(items)
  local seen, out = {}, {}
  for _, item in ipairs(items) do
    local key = string.format('%s:%d', item.filename or '', item.lnum or 0)
    if not seen[key] then
      seen[key] = true
      out[#out + 1] = item
    end
  end
  return out
end

--- Goto definition/type/impl: query all clients, dedupe identical hits, jump if one.
--- Telescope's lsp_* helpers use buf_request_all and concatenate every client's
--- result with no dedupe — two rust-analyzers (or RA returning declaration+def)
--- show as two identical picker rows.
--- @param method string  LSP method
--- @param title string
--- @param opts table|nil
function M.lsp_goto(method, title, opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  ---@param client vim.lsp.Client
  local function params_for(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end

  vim.lsp.buf_request_all(bufnr, method, params_for, function(results_per_client)
    local items = {}
    local encoding

    for client_id, res in pairs(results_per_client or {}) do
      if res.err then
        vim.notify(title .. ': ' .. (res.err.message or vim.inspect(res.err)), vim.log.levels.WARN)
      elseif res.result ~= nil then
        local client = vim.lsp.get_client_by_id(client_id)
        if client then
          encoding = encoding or client.offset_encoding
          local locs = res.result
          if not vim.islist(locs) then
            locs = { locs }
          end
          if #locs > 0 then
            vim.list_extend(items, vim.lsp.util.locations_to_items(locs, client.offset_encoding))
          end
        end
      end
    end

    items = dedupe_locations(items)

    if #items == 0 then
      vim.notify('No ' .. title .. ' found', vim.log.levels.INFO)
      return
    end

    if #items == 1 then
      local item = items[1]
      -- user_data is the original Location/LocationLink for show_document
      local loc = item.user_data
      if loc then
        vim.lsp.util.show_document(loc, encoding or 'utf-16', { focus = true, reuse_win = true })
      else
        vim.cmd.edit(vim.fn.fnameescape(item.filename))
        pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max(0, (item.col or 1) - 1) })
      end
      return
    end

    require('telescope.pickers')
      .new(opts, {
        prompt_title = title,
        finder = require('telescope.finders').new_table({
          results = items,
          entry_maker = require('telescope.make_entry').gen_from_quickfix(opts),
        }),
        previewer = require('telescope.config').values.qflist_previewer(opts),
        sorter = require('telescope.config').values.generic_sorter(opts),
        push_cursor_on_edit = true,
        push_tagstack_on_edit = true,
      })
      :find()
  end)
end

function M.lsp_definitions(opts)
  M.lsp_goto('textDocument/definition', 'LSP Definitions', opts)
end

function M.lsp_type_definitions(opts)
  M.lsp_goto('textDocument/typeDefinition', 'LSP Type Definitions', opts)
end

function M.lsp_implementations(opts)
  M.lsp_goto('textDocument/implementation', 'LSP Implementations', opts)
end

-- Function run when an LSP connects to a buffer
M.on_attach = function(_, bufnr)
  -- g-family for LSP (consistent navigation + actions)
  nmap('ga', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('rn', vim.lsp.buf.rename, '[R]e[n]ame')

  nmap('gd', M.lsp_definitions, '[G]oto [D]efinition')
  nmap('gD', M.lsp_type_definitions, '[G]oto Type [D]efinition')
  nmap('gr', function()
    M.lsp_references()
  end, '[G]oto [R]eferences (workspace)')
  nmap('gR', function()
    M.lsp_references({ include_deps = true })
  end, '[G]oto [R]eferences (incl. deps/.cargo)')
  nmap('gi', M.lsp_implementations, '[G]oto [I]mplementation')
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

  -- Toggle inlay hints (disabled by default due to 0.11.x bugs)
  nmap('<leader>ih', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, '[I]nlay [H]ints Toggle')

  -- Create a buffer-local :Format command
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local cmd_cache = {}
M.cmd_exists = function(cmd)
  if cmd_cache[cmd] ~= nil then return cmd_cache[cmd] end
  -- vim.fn.executable() is a built-in C check (no shell fork); os.execute()
  -- previously spawned /bin/sh per call, costing ~50-200ms at startup.
  local res = vim.fn.executable(cmd) == 1
  cmd_cache[cmd] = res
  return res
end

return M
