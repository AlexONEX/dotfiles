vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	vim.cmd("silent !taplo format %")
	vim.cmd("edit")
	vim.cmd("write")
end

_G.Ftplugin_Toml = M

vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Toml.format_and_save()<CR>", { noremap = true, silent = true, buffer = 0 })

vim.api.nvim_buf_create_user_command(0, "FormatAndSaveToml", function()
	M.format_and_save()
end, { desc = "Format and save TOML file" })
