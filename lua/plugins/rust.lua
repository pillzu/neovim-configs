return {
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false,
    init = function()
      -- Only wire up cargo-subspace when it's actually installed, so this config
      -- stays portable to machines without it — otherwise fall back to clippy.
      local has_subspace = vim.fn.executable('cargo-subspace') == 1
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            require('utils').on_attach(client, bufnr)

            -- rust-analyzer returns *grouped* code actions. The generic
            -- vim.lsp.buf.code_action handler (set as `ga` in utils.on_attach)
            -- renders those groups as a nested menu, which is why it takes two
            -- presses. rustaceanvim's own handler flattens them → single press.
            vim.keymap.set('n', 'ga', function() vim.cmd.RustLsp('codeAction') end,
              { buffer = bufnr, silent = true, desc = 'LSP: [C]ode [A]ction (rust)' })

            -- Re-apply our Telescope mappings last so rustaceanvim doesn't override them
            local tb = require('telescope.builtin')
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set('n', 'gd',  function() tb.lsp_definitions({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [D]efinition' }))
            vim.keymap.set('n', 'gD',  function() tb.lsp_type_definitions({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto Type [D]efinition' }))
            vim.keymap.set('n', 'gr',  function() tb.lsp_references({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [R]eferences' }))
            vim.keymap.set('n', 'gi',  function() tb.lsp_implementations({ jump_type = "never" }) end, vim.tbl_extend('force', opts, { desc = '[G]oto [I]mplementation' }))
            vim.keymap.set('n', 'gs',  function() tb.lsp_document_symbols() end, vim.tbl_extend('force', opts, { desc = '[D]ocument [S]ymbols' }))
            vim.keymap.set('n', 'gws', function() tb.lsp_dynamic_workspace_symbols() end, vim.tbl_extend('force', opts, { desc = '[W]orkspace [S]ymbols' }))
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
          settings = {
            ['rust-analyzer'] = {
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
              -- cargo-subspace integration (guarded above).
              -- Install: cargo install --locked cargo-subspace
              -- Requires: rustup component add rust-src
              check = has_subspace and {
                invocationStrategy = 'per_workspace_member',
                overrideCommand = { 'cargo-subspace', 'clippy', '$saved_file' },
              } or {
                command = 'clippy',
              },
              workspace = {
                discoverConfig = has_subspace and {
                  command = { 'cargo-subspace', 'discover', '{arg}' },
                  progressLabel = 'cargo-subspace',
                  filesToWatch = { 'Cargo.toml' },
                } or nil,
              },
              -- Performance: limit heavy background work in large workspaces
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
            },
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
