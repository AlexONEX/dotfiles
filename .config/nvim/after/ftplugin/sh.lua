vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt.isfname:remove("=")

local M = {}

function M.run_bash()
	vim.cmd("!bash %")
end

_G.Ftplugin_Bash = M

vim.keymap.set("n", "<F9>", ":lua Ftplugin_Bash.run_bash()<CR>", { noremap = true, silent = true, buffer = 0 })
