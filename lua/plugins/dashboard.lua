return {
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
      require('config').dashboard()
    end,
  },

}
