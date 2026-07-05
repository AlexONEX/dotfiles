vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.opt_local.colorcolumn = "120"
vim.opt_local.formatoptions:remove({ "o", "r" })

local function format_and_save()
  vim.lsp.buf.format({ async = false })
  vim.cmd("write")
end

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", format_and_save, opts)
vim.keymap.set("n", "<space>f", format_and_save, opts)
