local cmp = require("cmp")
require("cmp_nvim_lsp")
require("cmp_path")
require("cmp_buffer")
require("cmp_omni")
require("cmp_nvim_ultisnips")

-- Add this: safely require mini.icons
local has_mini_icons, MiniIcons = pcall(require, "mini.icons")
if not has_mini_icons then
  vim.notify(
    "mini.icons not found! Please install it or adjust nvim-cmp configuration.",
    vim.log.levels.WARN,
    { title = "Nvim-config" }
  )
end

cmp.setup {
  snippet = {
    expand = function(args)
      -- For `ultisnips` user.
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Esc>"] = cmp.mapping.close(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
  },
  sources = {
    { name = "nvim_lsp" }, -- For nvim-lsp
    { name = "ultisnips" }, -- For ultisnips user.
    { name = "path" }, -- for path completion
    { name = "buffer", keyword_length = 2 }, -- for buffer word completion
  },
  completion = {
    keyword_length = 1,
    completeopt = "menu,noselect",
  },
  view = {
    entries = "custom",
  },
  -- Modified formatting with null check for MiniIcons
  formatting = {
    format = function(_, vim_item)
      if has_mini_icons then
        local icon, hl = MiniIcons.get("lsp", vim_item.kind)
        vim_item.kind = icon .. " " .. vim_item.kind
        vim_item.kind_hl_group = hl
      end
      return vim_item
    end,
  },
}
cmp.setup.filetype("tex", {
  sources = {
    { name = "omni" },
    { name = "ultisnips" }, -- For ultisnips user.
    { name = "buffer", keyword_length = 2 }, -- for buffer word completion
    { name = "path" }, -- for path completion
  },
})
--  see https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-dark-theme-colors-to-the-menu
vim.cmd([[
  highlight! link CmpItemMenu Comment
  " gray
  highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
  " blue
  highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
  highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
  " light blue
  highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
  " pink
  highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
  highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
  " front
  highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
]])
