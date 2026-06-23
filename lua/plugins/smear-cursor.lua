return {
  "sphamba/smear-cursor.nvim",
  -- TEMP: disabled to isolate the stray-"A"-in-Telescope-prompt bug. If `gd`
  -- works clean with this off, smear-cursor is the culprit; re-enable then.
  enabled = false,
  event = "VeryLazy",
  opts = {
    -- Don't animate the cursor in insert mode. The Telescope/fzf prompt is an
    -- insert-mode floating buffer; smearing there leaks partial CSI escape
    -- sequences (e.g. the `A` tail of `ESC [ A`) into the prompt under tmux,
    -- which is why `gd` opened a picker pre-filled with a stray "A".
    smear_insert_mode = false,
    -- Reduce redraw/escape artifacts from drawing over the real cursor target.
    hide_target_hack = true,
    never_draw_over_target = true,
  },
}
