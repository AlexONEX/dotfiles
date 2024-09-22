local M = {}

-- Configuración general
vim.opt_local.wrap = false
vim.opt_local.sidescroll = 5
vim.opt_local.sidescrolloff = 2
vim.opt_local.colorcolumn = "100"
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.formatoptions:remove({ "o", "r" })

-- Función para ejecutar Python
function M.run_python()
	vim.cmd('AsyncRun python -u "%"')
end

-- Función para formatear con Ruff y guardar
function M.format_and_save()
	vim.cmd("silent !ruff format %")
	vim.cmd("silent !ruff check --fix %")
	vim.cmd("edit") -- Recarga el archivo
	vim.cmd("write")
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<F9>",
	':lua require("python").run_python()<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_buf_set_keymap(
	0,
	"n",
	"<C-s>",
	':lua require("python").format_and_save()<CR>',
	{ noremap = true, silent = true }
)

return M
