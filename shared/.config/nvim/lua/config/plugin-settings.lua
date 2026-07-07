-- Plugin settings (migrated from viml_conf/plugins.vim)

local autoload = require("autoload")

-- Command abbreviations for Lazy
autoload.cabbrev("pi", "Lazy install")
autoload.cabbrev("pud", "Lazy update")
autoload.cabbrev("pc", "Lazy clean")
autoload.cabbrev("ps", "Lazy sync")

-- UltiSnips settings
vim.g.UltiSnipsExpandTrigger = "<c-j>"
vim.g.UltiSnipsEnableSnipMate = 0
vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "my_snippets" }

-- vim-xkbswitch settings
vim.g.XkbSwitchEnabled = 1

-- vim-markdown settings
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 1
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 0
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_toml_frontmatter = 1
vim.g.vim_markdown_json_frontmatter = 1
vim.g.vim_markdown_toc_autofit = 1

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
