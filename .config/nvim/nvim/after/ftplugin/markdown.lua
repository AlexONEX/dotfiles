local M = {}

-- Configuración general
vim.opt_local.concealcursor = 'c'
vim.opt_local.synmaxcol = 3000
vim.opt_local.wrap = true
vim.opt_local.formatoptions:remove({ 'o', 'r' })

-- Funciones auxiliares
local function add_list_symbol(start_line, end_line)
  for line = start_line, end_line do
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local indent = text:match('^%s*')
    local new_text = indent .. '+ ' .. text:sub(#indent + 1)
    vim.api.nvim_buf_set_lines(0, line - 1, line, false, {new_text})
  end
end

local function add_line_break(start_line, end_line)
  for line = start_line, end_line do
    local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    vim.api.nvim_buf_set_lines(0, line - 1, line, false, {text .. '\\'})
  end
end

-- Función para formatear y guardar
function M.format_and_save()
  vim.lsp.buf.format()
  vim.cmd('write')
end

-- Mapeo de teclas
vim.api.nvim_buf_set_keymap(0, 'n', '+', ':set operatorfunc=v:lua.add_list_symbol<CR>g@', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'x', '+', ":<C-U>lua add_list_symbol(vim.fn.line(\"'<\"), vim.fn.line(\"'>\"))<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '\\', ':set operatorfunc=v:lua.add_line_break<CR>g@', { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'x', '\\', ":<C-U>lua add_line_break(vim.fn.line(\"'<\"), vim.fn.line(\"'>\"))<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', ':lua require("markdown").format_and_save()<CR>', { noremap = true, silent = true })

-- Configuración de footnotes si está disponible
if vim.fn.exists(':FootnoteNumber') == 1 then
  vim.api.nvim_buf_set_keymap(0, 'n', '^^', ":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, 'i', '^^', "<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, 'i', '@@', "<Plug>ReturnFromFootnote", { silent = true })
  vim.api.nvim_buf_set_keymap(0, 'n', '@@', "<Plug>ReturnFromFootnote", { silent = true })
end

-- Text objects for Markdown code blocks
vim.api.nvim_buf_set_keymap(0, 'x', 'ic', ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'x', 'ac', ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'o', 'ic', ":<C-U>lua require('text_obj').MdCodeBlock('i')<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, 'o', 'ac', ":<C-U>lua require('text_obj').MdCodeBlock('a')<CR>", { noremap = true, silent = true })

return M