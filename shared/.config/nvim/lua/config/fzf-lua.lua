local fzf = require("fzf-lua")

fzf.register_ui_select()

fzf.setup {
  defaults = {
    file_icons = "mini",
  },
  winopts = {
    row = 0.5,
    height = 0.7,
  },
  files = {
    previewer = false,
  },
}

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Fuzzy grep tags in help files" })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<cr>", { desc = "Fuzzy search buffer tags" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy search opened buffers" })
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<cr>", { desc = "Fuzzy search old files" })
vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document diagnostics" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua colorschemes<cr>", { desc = "Fuzzy find colorscheme" })
