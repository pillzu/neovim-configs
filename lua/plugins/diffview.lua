-- Diffview plugin with auto-refresh for grok CLI integration
-- Automatically refreshes git diffs when grok makes changes

-- Helper to check if file is git ignored
local function is_git_ignored(filepath)
  vim.fn.system('git check-ignore -q ' .. vim.fn.shellescape(filepath))
  return vim.v.shell_error == 0
end

-- Update the left pane of diffview
local function update_diffview_pane()
  pcall(function()
    local lib = require('diffview.lib')
    local view = lib.get_current_view()
    if view then
      view:update_files()
    end
  end)
end

-- Register with directory watcher for auto-refresh
local function setup_directory_watcher()
  local ok, dir_watcher = pcall(require, 'custom.directory-watcher')
  if not ok then
    return
  end

  dir_watcher.registerOnChangeHandler('diffview', function(filepath, events)
    -- Check if this is a .git directory change or a non-ignored file
    local is_in_dot_git_dir = filepath:match('/%.git/') or filepath:match('^%.git/')
    
    if is_in_dot_git_dir or not is_git_ignored(filepath) then
      vim.schedule(function()
        update_diffview_pane()
      end)
    end
  end)
end

return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
  keys = {
    { '<leader>dv', '<cmd>DiffviewOpen<cr>', desc = 'Open Diffview' },
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Close Diffview' },
    { '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History (current file)' },
    { '<leader>dH', '<cmd>DiffviewFileHistory<cr>', desc = 'File History (all)' },
    { '<leader>dr', '<cmd>DiffviewRefresh<cr>', desc = 'Refresh Diffview' },
  },
  config = function()
    local diffview = require('diffview')
    local actions = require('diffview.actions')

    diffview.setup({
      diff_binaries = false,
      enhanced_diff_hl = true,
      use_icons = true,
      show_help_hints = true,
      watch_index = true,

      icons = {
        folder_closed = "",
        folder_open = "",
      },

      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },

      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = false,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },

      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },

      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },

      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_panel = {
          { "n", "j", actions.next_entry, { desc = "Next entry" } },
          { "n", "k", actions.prev_entry, { desc = "Previous entry" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
          { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
          { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
          { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
          { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
          { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open the file" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_history_panel = {
          { "n", "g!", actions.options, { desc = "Open the option panel" } },
          { "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
          { "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
          { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
          { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
          { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
          { "n", "j", actions.next_entry, { desc = "Next entry" } },
          { "n", "k", actions.prev_entry, { desc = "Previous entry" } },
          { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        option_panel = {
          { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
          { "n", "q", actions.close, { desc = "Close the panel" } },
        },
      },
    })

    -- Setup directory watcher for auto-refresh
    setup_directory_watcher()

    -- Auto-refresh on focus gained
    vim.api.nvim_create_autocmd('FocusGained', {
      group = vim.api.nvim_create_augroup('DiffviewAutoRefresh', { clear = true }),
      callback = update_diffview_pane,
    })

    -- Close diffview properly when leaving
    vim.api.nvim_create_autocmd('User', {
      pattern = 'DiffviewViewLeave',
      callback = function()
        vim.cmd(':DiffviewClose')
      end,
    })
  end,
}
