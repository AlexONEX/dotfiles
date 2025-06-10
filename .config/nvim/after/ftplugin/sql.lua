vim.opt_local.commentstring = "--\\ %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

local M = {}

function M.format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

_G.Ftplugin_Sql = M

vim.keymap.set("n", "<C-s>", ":lua Ftplugin_Sql.format_and_save()<CR>", { noremap = true, silent = true, buffer = 0 })
