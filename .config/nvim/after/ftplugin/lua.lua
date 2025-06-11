vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.tabstop = 2
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

function M.format_and_save()
	if utils.executable("stylua") then
		vim.cmd("silent !stylua %")
		vim.cmd("edit")
		vim.cmd("write")
		vim.notify("Formatted with StyLua", vim.log.levels.INFO)
	else
		vim.notify("StyLua not found. Install with: cargo install stylua", vim.log.levels.WARN)
	end
end

function M.run_lua()
	vim.cmd("luafile %")
	vim.notify("Lua file executed", vim.log.levels.INFO)
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
