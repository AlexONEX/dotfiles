vim.bo.commentstring = "--\\ %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

_G.Ftplugin_Sql = M

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<C-s>", function()
	Ftplugin_Sql.format_and_save()
end, opts)
