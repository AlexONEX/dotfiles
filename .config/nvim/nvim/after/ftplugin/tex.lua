-- Configuración general
vim.opt_local.textwidth = 120
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove({ "o", "r" })

-- Función para formatear y guardar
local function format_and_save()
	vim.lsp.buf.format()
	vim.cmd("write")
end

-- Función para compilar LaTeX
local function compile_latex()
	vim.cmd("AsyncRun pdflatex -interaction=nonstopmode -synctex=1 %")
end

-- Crear comandos de usuario
vim.api.nvim_create_user_command("FormatAndSaveLatex", format_and_save, {})
vim.api.nvim_create_user_command("CompileLatex", compile_latex, {})

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, "n", "<C-s>", ":FormatAndSaveLatex<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "n", "<F9>", ":CompileLatex<CR>", { noremap = true, silent = true })
