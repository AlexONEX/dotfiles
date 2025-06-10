vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	vim.cmd("silent !stylua %")
	vim.cmd("edit")
	vim.cmd("write")
end

function M.run_lua()
	vim.cmd("luafile %")
end

_G.Ftplugin_Lua = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Lua.format_and_save()
end, opts)
vim.keymap.set("n", "<F9>", function()
	Ftplugin_Lua.run_lua()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Lua.format_and_save()
end, opts)
