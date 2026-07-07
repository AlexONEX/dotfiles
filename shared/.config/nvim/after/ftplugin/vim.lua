vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.foldmethod = "marker"
vim.opt_local.foldmarker = "{{{,}}}"
vim.opt_local.formatoptions:remove { "o", "r" }

local M = {}

function M.run_vim_script()
  vim.cmd("source %")
  vim.notify("Vim script executed", vim.log.levels.INFO)
end

_G.M = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
  M.run_vim_script()
end, opts)
