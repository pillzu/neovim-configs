return {
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()

      local function border(hl_name)
        return {
          { '╭', hl_name },
          { '─', hl_name },
          { '╮', hl_name },
          { '│', hl_name },
          { '╯', hl_name },
          { '─', hl_name },
          { '╰', hl_name },
          { '│', hl_name },
        }
      end

      cmp.setup {
        window = {
          completion = {
            side_padding = 1,
            scrollbar = false,
            border = border 'CmpPMenu',
          },
          documentation = {
            border = border 'CmpDoc',
            winhighlight = 'Normal:CmpDoc',
          },
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local kind_icons = {
              Text = '󰉿', Method = '󰆧', Function = '󰊕', Constructor = '',
              Field = '󰜢', Variable = '󰀫', Class = '󰠱', Interface = '',
              Module = '', Property = '󰜢', Unit = '󰑭', Value = '󰎠',
              Enum = '', Keyword = '󰌋', Snippet = '', Color = '󰏘',
              File = '󰈙', Reference = '󰈇', Folder = '󰉋', EnumMember = '',
              Constant = '󰏿', Struct = '󰙅', Event = '', Operator = '󰆕',
              TypeParameter = '󰬛',
            }
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '', vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = '[LSP]', luasnip = '[Snippet]', buffer = '[Buffer]',
              path = '[Path]', calc = '[Calc]', nvim_lua = '[Lua]',
            })[entry.source.name] or ''
            return vim_item
          end,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-s>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          -- LSP first (highest priority) so Text/Buffer comes after
          { name = 'nvim_lsp',                 priority = 1000, keyword_length = 3 },
          { name = 'nvim_lsp_signature_help',  priority = 900 },
          { name = 'luasnip',                  priority = 800 },
          { name = 'nvim_lua',                 priority = 400, keyword_length = 2 },
          { name = 'buffer',                   priority = 300, keyword_length = 2 },
          { name = 'path',                     priority = 200 },
          { name = 'calc',                     priority = 100 },
        },
      }
    end,
  },
}
