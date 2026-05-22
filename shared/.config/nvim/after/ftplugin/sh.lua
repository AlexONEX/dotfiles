vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })
vim.opt.isfname:remove("=")

local M = {}
local utils = require("utils")

function M.run_bash()
	if utils.executable("bash") then
		vim.cmd("!bash %")
	else
		vim.notify("Bash not found", vim.log.levels.ERROR)
	end
end

function M.format_bash()
	if utils.executable("shfmt") then
		vim.cmd("silent !shfmt -w %")
		vim.cmd("edit")
		vim.notify("Formatted with shfmt", vim.log.levels.INFO)
	else
		vim.notify("shfmt not found", vim.log.levels.WARN)
	end
end

_G.Ftplugin_Bash = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<F9>", function()
	Ftplugin_Bash.run_bash()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Bash.format_bash()
end, opts)
