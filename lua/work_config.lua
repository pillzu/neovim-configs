-- Safe loader for optional work-only settings.
--
-- Personal clones have no lua/work.lua → empty defaults (no work paths, no
-- subspace patterns). Work machines copy work.example.lua → work.lua
-- (gitignored). Nothing work-related is committed.

local defaults = {
  nvim_tree_disable_git_dirs = {},
  rust_subspace_root_patterns = {},
}

local ok, work = pcall(require, 'work')
if not ok or type(work) ~= 'table' then
  return defaults
end

---@param t any
---@return table
local function as_table(t)
  return type(t) == 'table' and t or {}
end

return {
  nvim_tree_disable_git_dirs = as_table(work.nvim_tree_disable_git_dirs),
  rust_subspace_root_patterns = as_table(work.rust_subspace_root_patterns),
}
