-- Plugin settings (migrated from viml_conf/plugins.vim)

local autoload = require("autoload")

-- Command abbreviations for Lazy
autoload.cabbrev("pi", "Lazy install")
autoload.cabbrev("pud", "Lazy update")
autoload.cabbrev("pc", "Lazy clean")
autoload.cabbrev("ps", "Lazy sync")

-- vim-xkbswitch settings
vim.g.XkbSwitchEnabled = 1

-- markdown-preview settings
if vim.g.is_win or vim.g.is_mac then
  vim.g.mkdp_auto_close = 0
  vim.keymap.set("n", "<M-m>", "<cmd>MarkdownPreview<CR>", { silent = true, desc = "start markdown preview" })
  vim.keymap.set("n", "<M-S-m>", "<cmd>MarkdownPreviewStop<CR>", { silent = true, desc = "stop markdown preview" })
end

-- unicode.vim settings
vim.keymap.set("n", "ga", "<Plug>(UnicodeGA)")

-- asyncrun.vim settings
vim.g.asyncrun_open = 6
if vim.g.is_win then
  vim.g.asyncrun_encs = "gbk"
end
