return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      adapters = {
        http = {
          xai = function()
            return require('codecompanion.adapters').extend('xai', {
              env = {
                api_key = "cmd:op read 'op://Employee/xAI API Key/password' --no-newline",
              },
              schema = {
                model = {
                  default = 'grok-4-fast-reasoning',
                },
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = 'xai',
        },
        inline = {
          adapter = 'xai',
        },
        agent = {
          adapter = 'xai',
        },
      },
    },
  },
}
