vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove { "o", "r" }

if vim.fn.line("$") > 500 then
  vim.opt_local.syntax = "OFF"
end
