local M = {}

-- Configuración general
vim.opt_local.formatoptions:remove({ 'o', 'r' })

-- Desactivar sintaxis para archivos YAML grandes
if vim.fn.line('$') > 500 then
  vim.opt_local.syntax = 'OFF'
end

-- Función para formatear y guardar
function M.format_and_save()
  vim.lsp.buf.format()
  vim.cmd('write')
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':lua require("yaml").format_and_save()<CR>', { noremap = true, silent = true })

return M
