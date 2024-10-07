local M = {}

-- Configuración general
vim.opt_local.commentstring = "--\\ %s"
vim.opt_local.formatoptions:remove({ "o", "r" })

-- Función para formatear y guardar
function M.format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<C-s>",
	':lua require("sql").format_and_save()<CR>',
	{ noremap = true, silent = true }
)

return M
