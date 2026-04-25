return {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        pyflakes = { enabled = true },
        pylint = { enabled = false },
        mccabe = { enabled = false },
        black = { enabled = true },
        isort = { enabled = true },
      },
    },
  },
}