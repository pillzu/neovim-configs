return {
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        background_colour = "#000000",
        render = 'wrapped-compact',
        max_width = 90,
        max_height = 4,
      })
    end
  }
}
