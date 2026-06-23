# groktmux.nvim — Implementation Plan

Grok ↔ Neovim integration via tmux + post-disk review. No ACP, no JSON-RPC, no FS
proxy. A thin coordination layer over tooling already owned (tmux, gitsigns,
diffview, custom/yank, custom/directory-watcher).

## Resolved design (from grill-me interview)

| Concern | Resolution |
|---|---|
| Architecture | Terminal/tmux Grok + post-disk review. Delete old `lua/grok/` ACP stack. |
| Feed delivery | `tmux` bracketed-paste into Grok pane; clipboard fallback. |
| Anti-clobber | Feed current state (incl. unsaved buffer) so Grok edits from reality. |
| Review baseline | `git stash create` at dispatch → SHA (falls back to `HEAD` on clean tree). |
| Review surface | Existing gitsigns, base repointed via `change_base(sha, true)`. No vimdiff. |
| Reject / keep / modify | gitsigns `reset_hunk` / `stage_hunk` / just edit. |
| Cross-file walk | diffview `<tab>` + gitsigns hunk nav within file. |
| Review trigger | Auto-detect via scoped file-write quiescence (debounced). |
| Tab completion | Parked (not built). |
| Namespace | `lua/groktmux/`. |
| Testing | No formal TDD; validate manually / ad-hoc harness only where needed. |

## Phase 0 — Teardown
- Delete `lua/grok/` (init, acp_client, composer, chat, completion, context, ui, verify).
- Delete `lua/plugins/grok.lua` (bespoke-agent spec).
- Keep `lua/plugins/grok-integration.lua`, `custom/yank.lua`, `custom/hotreload.lua`,
  `custom/directory-watcher.lua`, gitsigns, diffview.

## Phase 1 — Feed (`lua/groktmux/feed.lua` + `tmux.lua`)
`tmux.lua`:
- `find_grok_pane()`: if `$TMUX`, `tmux list-panes -F '#{pane_id} #{pane_current_command}'`,
  pick pane whose command isn't `nvim`. Cache. `:GrokAttachPane` overrides.
- `send(text)`: `tmux load-buffer -b grokfeed -` (stdin) → `tmux paste-buffer -b grokfeed
  -t <pane> -p -d` (bracketed paste = one prompt) → `send-keys -t <pane> Enter`.
- Fallback: `setreg('+', text)` + notify when no pane / no `$TMUX`.

`feed.lua`:
- Target: visual selection (yank.get_visual_bounds/get_visual_selection) else current
  line ± N (default 3).
- Header: `relpath:line-range` (yank.format_line_range).
- Body: current buffer lines (nvim_buf_get_lines, includes unsaved).
- Compose `header\n```\n<excerpt>\n```\n<task>`; task via `vim.ui.input`.
- `<leader>gG` variant: append `git diff -U3 -- <file>` (opt-in).
- Calls `snapshot.take()` immediately before send.

## Phase 2 — Snapshot + Review (`snapshot.lua` + `review.lua`)
`snapshot.lua`:
- `take()`: `git stash create` (vim.system async). Empty → `HEAD`. Store SHA, arm watcher.
- `current()`: active baseline SHA.

`review.lua`:
- `open()`: `gitsigns.change_base(snapshot.current(), true)` + `:DiffviewOpen <sha>`.
- `clear()`: `change_base(nil, true)`, disarm watcher.
- Reject/keep/modify reuse existing gitsigns keys (no new code).

## Phase 3 — Auto-detect quiescence (`detect.lua`)
- Armed by `snapshot.take()`, disarmed by `review.clear()`.
- Own `uv.new_fs_event()` set, SCOPED: dirs of open buffers, grows per touched dir,
  `recursive=false`. Never the repo root (repo-safe; do NOT use the global
  recursive directory-watcher for this).
- Each write event resets a debounce timer (default 1800ms). Expiry after burst →
  `vim.schedule(review.open)`.
- Re-fire safe: base pinned to dispatch SHA; late writes = more hunks (DiffviewRefresh).
- Hard cap: auto-disarm after max idle (~5 min).

## Phase 4 — Wiring (`init.lua` + `lua/plugins/groktmux.lua`)
- Commands: `:GrokFeed`, `:GrokFeedDiff`, `:GrokReview`, `:GrokReviewClear`, `:GrokAttachPane`.
- which-key `<leader>g`: `gg` ask, `ge` edit, `gG` edit+diff, `gr` manual review, `gx` clear, `gP` attach pane.
- All tmux calls no-op gracefully when `$TMUX` unset.

## Status
- [x] Phase 0 — teardown
- [x] Phase 1 — feed + tmux
- [x] Phase 2 — snapshot + review
- [x] Phase 3 — auto-detect
- [x] Phase 4 — wiring

## Validation
- All modules load clean in headless nvim; `feed.compose()` output verified.
- `git stash create` snapshot primitive + `gitsigns.change_base(sha, true)` confirmed.
- Still untested live: tmux pane discovery + bracketed-paste delivery and the
  fs_event quiescence auto-fire (need a real tmux session with Grok running).
