local M = {}

-- Configuración general
vim.opt_local.textwidth = 120
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove({ 'o', 'r' })

-- Función para formatear y guardar
function M.format_and_save()
  vim.lsp.buf.format()
  vim.cmd('write')
end

-- Función para compilar LaTeX
function M.compile_latex()
  vim.cmd('AsyncRun pdflatex -interaction=nonstopmode -synctex=1 %')
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':lua require("tex").format_and_save()<CR>', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<F9>', ':lua require("tex").compile_latex()<CR>', { noremap = true, silent = true })

return M
