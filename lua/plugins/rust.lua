return {
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false,
    init = function()
      -- cargo-subspace only when installed AND the project root matches a pattern
      -- from the optional work overlay (lua/work.lua). Personal machines leave
      -- rust_subspace_root_patterns empty → normal Cargo loading + clippy.
      local has_subspace = vim.fn.executable('cargo-subspace') == 1
      local subspace_patterns = require('work_config').rust_subspace_root_patterns

      ---@param root string|nil
      ---@return boolean
      local function root_matches_subspace(root)
        if not root or root == '' or #subspace_patterns == 0 then
          return false
        end
        for _, pat in ipairs(subspace_patterns) do
          if root:find(pat, 1, false) then
            return true
          end
        end
        return false
      end

      ---@param project_root string|nil
      ---@return boolean
      local function use_subspace(project_root)
        return has_subspace and root_matches_subspace(project_root)
      end

      ---@param project_root string|nil
      ---@param default_settings table|nil
      ---@return table
      local function ra_settings(project_root, default_settings)
        local subspace = use_subspace(project_root)
        local ra = {
          inlayHints = {
            bindingModeHints = { enable = false },
            chainingHints = { enable = false },
            closingBraceHints = { enable = false },
            closureReturnTypeHints = { enable = 'never' },
            lifetimeElisionHints = { enable = 'never' },
            parameterHints = { enable = false },
            reborrowHints = { enable = 'never' },
            renderColons = false,
            typeHints = { enable = false },
          },
          -- Install: cargo install --locked cargo-subspace
          -- Requires: rustup component add rust-src
          check = subspace and {
            invocationStrategy = 'per_workspace_member',
            overrideCommand = { 'cargo-subspace', 'clippy', '$saved_file' },
          } or {
            command = 'clippy',
          },
          workspace = {
            -- Lazy project graph only on mono; elsewhere let RA load Cargo normally.
            discoverConfig = subspace and {
              command = { 'cargo-subspace', 'discover', '{arg}' },
              progressLabel = 'cargo-subspace',
              filesToWatch = { 'Cargo.toml' },
            } or nil,
          },
          -- Performance: limit heavy background work in large workspaces.
          -- Don't eagerly analyze every crate + dependency in the discovered
          -- project at startup. With this off, RA analyzes lazily — only the
          -- files/crates you actually open get type-checked. This is the single
          -- biggest lever against the startup "index the whole world" pass and
          -- its memory spike. Trade-off: the first goto-def into a not-yet-seen
          -- crate is a touch slower; everything after is cached.
          cachePriming = { enable = false },
          files = {
            -- Let rust-analyzer do its own efficient, notify-based watching
            -- instead of Neovim registering a libuv watcher per file. On a
            -- large project the client-side watcher can spawn tens of thousands of
            -- watchers and stall the UI; 'server' offloads that to RA.
            watcher = 'server',
            -- Keep these large/irrelevant trees out of RA's project model so
            -- it never indexes or watches them. Paths are relative to the
            -- workspace root.
            excludeDirs = {
              'target',
              '.git',
              'submodules',
              '.venv',
              'node_modules',
              'bazel-out',
            },
          },
          procMacro = { enable = true, attributes = { enable = true } },
          cargo = {
            buildScripts = { enable = true },
            allTargets = false, -- only check the active target, not all
            -- Isolate rust-analyzer's build cache from terminal cargo so
            -- RA's clippy-on-save and your `cargo build` never contend on
            -- the same target/ lock or invalidate each other's incremental
            -- cache. `targetDir` covers RA's own analysis builds; extraEnv
            -- redirects the cargo-subspace clippy flycheck too.
            targetDir = true, -- -> target/rust-analyzer
            extraEnv = { CARGO_TARGET_DIR = 'target/rust-analyzer' },
          },
        }

        return vim.tbl_deep_extend('force', default_settings or {}, {
          ['rust-analyzer'] = ra,
        })
      end

      vim.g.rustaceanvim = {
        server = {
          -- Re-evaluate subspace vs normal Cargo from the attached project root
          -- (not nvim's launch cwd), so matching monorepos get discover and
          -- smaller crates do not.
          settings = ra_settings,
          on_attach = function(client, bufnr)
            require('utils').on_attach(client, bufnr)

            -- Re-apply maps after utils.on_attach so rustaceanvim/grouped RA
            -- handlers win over the generic ones (and over any other client).
            local u = require('utils')
            local tb = require('telescope.builtin')
            local opts = { buffer = bufnr, silent = true }

            -- Grouped code actions: rustaceanvim flattens them → single `ga`.
            vim.keymap.set('n', 'ga', function()
              vim.cmd.RustLsp('codeAction')
            end, vim.tbl_extend('force', opts, { desc = 'LSP: Code Action (rust)' }))

            -- Hover with rustaceanvim actions (overrides generic K from on_attach).
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp({ 'hover', 'actions' })
            end, vim.tbl_extend('force', opts, { desc = 'Hover (rust)' }))

            vim.keymap.set('n', '<leader>rr', function()
              vim.cmd.RustAnalyzer('restart')
            end, vim.tbl_extend('force', opts, { desc = 'RA: Restart (rediscover)' }))

            vim.keymap.set('n', '<leader>rR', function()
              vim.cmd.RustLsp('reloadWorkspace')
            end, vim.tbl_extend('force', opts, { desc = 'RA: Reload Workspace' }))

            vim.keymap.set('n', 'gd', u.lsp_definitions, vim.tbl_extend('force', opts, { desc = '[G]oto [D]efinition' }))
            vim.keymap.set('n', 'gD', u.lsp_type_definitions, vim.tbl_extend('force', opts, { desc = '[G]oto Type [D]efinition' }))
            vim.keymap.set('n', 'gr', function()
              u.lsp_references()
            end, vim.tbl_extend('force', opts, { desc = '[G]oto [R]eferences (workspace)' }))
            vim.keymap.set('n', 'gR', function()
              u.lsp_references({ include_deps = true })
            end, vim.tbl_extend('force', opts, { desc = '[G]oto [R]eferences (incl. deps)' }))
            vim.keymap.set('n', 'gi', u.lsp_implementations, vim.tbl_extend('force', opts, { desc = '[G]oto [I]mplementation' }))
            vim.keymap.set('n', 'gs', function()
              tb.lsp_document_symbols()
            end, vim.tbl_extend('force', opts, { desc = '[D]ocument [S]ymbols' }))
            vim.keymap.set('n', 'gws', function()
              tb.lsp_dynamic_workspace_symbols()
            end, vim.tbl_extend('force', opts, { desc = '[W]orkspace [S]ymbols' }))
          end,
          capabilities = vim.tbl_deep_extend(
            'force',
            vim.lsp.protocol.make_client_capabilities(),
            require('cmp_nvim_lsp').default_capabilities()
          ),
          -- Fix slow quit by forcing immediate LSP shutdown
          flags = {
            exit_timeout = 0,
          },
        },
        tools = {
          which_key = false,
          hover_actions = { enable = false },
        },
      }
    end,
  },
}
