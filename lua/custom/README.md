# Grok CLI Integration for Neovim

This directory contains custom modules that enhance Neovim's compatibility with the `grok` CLI (Claude-code equivalent).

Based on the article: https://xata.io/blog/configuring-neovim-coding-agents

## Features

### 1. Hot Reload (`hotreload.lua`)
Automatically reloads buffers when grok edits files externally. No more `:e!` or manual refreshing!

- Uses libuv filesystem events for efficient watching
- Triggers on FocusGained, TermLeave, BufEnter, etc.
- Skips modified buffers (won't overwrite your unsaved changes)
- Ignores special buffers (diffview://, fugitive://, etc.)

### 2. Directory Watcher (`directory-watcher.lua`)
Low-level filesystem monitoring using libuv's `fs_event`.

- Debounced callbacks to avoid excessive updates
- Can register multiple handlers for different purposes
- Automatically starts watching when entering a directory

### 3. Yank with Paths (`yank.lua`)
Copy code references with file paths for easy pasting into grok.

#### Keymaps

| Mode   | Keymap       | Description                              |
|--------|--------------|------------------------------------------|
| Visual | `<leader>yr` | Yank selection with relative path        |
| Visual | `<leader>ya` | Yank selection with absolute path        |
| Visual | `<leader>yp` | Yank content with relative path prefix   |
| Normal | `<leader>yr` | Yank relative path with line number      |
| Normal | `<leader>ya` | Yank absolute path with line number      |
| Normal | `<leader>yf` | Yank relative file path (no line number) |
| Normal | `<leader>yF` | Yank absolute file path (no line number) |

Example output when yanking lines 10-15 in `src/main.lua`:
```
src/main.lua:10-15
```

## Plugins Added

### diffview.nvim (`lua/plugins/diffview.lua`)
Enhanced git diff viewer with auto-refresh when grok makes changes.

| Keymap       | Description                  |
|--------------|------------------------------|
| `<leader>dv` | Open Diffview                |
| `<leader>dc` | Close Diffview               |
| `<leader>dh` | File history (current file)  |
| `<leader>dH` | File history (all files)     |
| `<leader>dr` | Refresh Diffview             |

Within Diffview:
- `s` - Stage/unstage entry
- `S` - Stage all
- `U` - Unstage all
- `R` - Refresh files
- `q` - Close diffview

## Workflow Tips (Neovim + grok in tmux)

1. **Run grok in a separate tmux pane**: Use tmux splits to have Neovim and grok side by side
2. **See changes instantly**: When grok edits files, they auto-reload in Neovim
3. **Review changes**: Use `<leader>dv` to open Diffview and see what grok changed
4. **Copy code references**: Select code and press `<leader>yr` to yank with path, then paste into grok
