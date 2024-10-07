local M = {}

-- Configuración general
vim.opt_local.formatoptions:remove({ 'o', 'r' })

-- Función para formatear con Prettier y guardar
function M.format_and_save()
  vim.cmd('silent !prettier --write %')
  vim.cmd('edit') -- Recarga el archivo
  vim.cmd('write')
end

-- Función para ejecutar TypeScript
function M.run_typescript()
  vim.cmd('AsyncRun ts-node %')
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':lua require("typescript").format_and_save()<CR>', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<F9>', ':lua require("typescript").run_typescript()<CR>', { noremap = true, silent = true })

return M
