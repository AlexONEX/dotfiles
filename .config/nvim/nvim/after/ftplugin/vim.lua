local M = {}

-- Configuración general
vim.opt_local.formatoptions:remove({ 'o', 'r' })
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'utils#VimFolds(v:lnum)'
vim.opt_local.foldtext = 'utils#MyFoldText()'
vim.opt_local.keywordprg = ':help'

-- Función para formatear y guardar
function M.format_and_save()
  vim.lsp.buf.format()
  vim.cmd('write')
end

-- Función para ejecutar el script Vim
function M.run_vim_script()
  vim.cmd('source %')
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, 'n', '<F9>', ':lua require("vim").run_vim_script()<CR>', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':lua require("vim").format_and_save()<CR>', { noremap = true, silent = true })

return M
