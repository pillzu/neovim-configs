return {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        pyflakes = { enabled = true },
        pylint = { enabled = false },
        mccabe = { enabled = false },
        -- Every formatter off, so LSP-fallback formatting can never reach
        -- autopep8: under Python >= 3.12 it wraps long lines inside f-string
        -- braces (PEP 701), which is a SyntaxError on older interpreters.
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        black = { enabled = false },
        isort = { enabled = false },
      },
    },
  },
}
