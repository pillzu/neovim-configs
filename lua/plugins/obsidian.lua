return {
  "epwalsh/obsidian.nvim",
  lazy = false,
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre /mnt/a/Second_Brain/second-brain/**.md",
    "BufNewFile /mnt/a/Second_Brain/second-brain/**.md",
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    dir = "/mnt/a/Second_Brain/second-brain",
    notes_subdir = "coding",

    completion = {
      nvim_cmp = true,
      min_chars = 2,
      new_notes_location = "current_dir",
      prepend_note_id = true
    },

    disable_frontmatter = true,

    mappings = {
    },

    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,

    -- Optional, customize the backlinks interface.
    backlinks = {
      -- The default height of the backlinks pane.
      height = 10,
      -- Whether or not to wrap lines.
      wrap = true,
    },
  },

  config = function(_, opts)
    require('obsidian').setup(opts)

    local obs_remap = function(keymap, action, desc)
      vim.keymap.set('n', '<leader>' .. keymap, action, { desc = '[O]bsidian: ' .. desc, expr = true, noremap = false })
    end

    obs_remap('on', function()
      local filename = vim.fn.input("Enter a note name: ")
      return "<cmd>ObsidianNew " .. filename .. "<CR>"
    end, "[N]ew file")

    obs_remap('os', function()
      return "<cmd>ObsidianSearch<CR>"
    end, "[S]earch Notes")

    obs_remap('oq', function()
      return "<cmd>ObsidianQuickSwitch<CR>"
    end, "[Q]uick Switch")

    obs_remap('of', function()
      return "<cmd>ObsidianFollowLink<CR>"
    end, "[F]ollow Link")
  end

}
