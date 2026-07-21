-- Work-only Neovim settings. Copy to lua/work.lua on work machines:
--
--   cp lua/work.example.lua lua/work.lua
--
-- lua/work.lua is gitignored. Personal machines need no file — work_config
-- falls back to empty defaults so there is zero blast radius either way.

return {
  -- Huge trees where nvim-tree full-tree git status is unusable.
  nvim_tree_disable_git_dirs = {
    vim.fn.expand('~/path/to/huge-repo'),
    -- vim.fn.expand('~/path/to/another-huge-repo'),
  },

  -- Enable cargo-subspace for rust-analyzer when the project root matches any
  -- of these Lua patterns (plain find, not regex with special flags).
  -- Small crates leave this empty or simply don't match → normal Cargo+clippy.
  rust_subspace_root_patterns = {
    'my%-mono', -- e.g. my-mono, my-mono-wt/...
  },
}
