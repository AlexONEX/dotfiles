vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}
local utils = require("utils")

function M.format_and_save()
	if utils.executable("taplo") then
		vim.cmd("silent !taplo format %")
		vim.cmd("edit")
		vim.cmd("write")
		vim.notify("Formatted with taplo", vim.log.levels.INFO)
	else
		vim.notify("taplo not found", vim.log.levels.WARN)
		vim.cmd("write")
	end
end

_G.Ftplugin_Toml = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Toml.format_and_save()
end, opts)
vim.keymap.set("n", "<space>f", function()
	Ftplugin_Toml.format_and_save()
end, opts)

vim.api.nvim_buf_create_user_command(0, "FormatAndSaveToml", function()
	M.format_and_save()
end, { desc = "Format and save TOML file" })
